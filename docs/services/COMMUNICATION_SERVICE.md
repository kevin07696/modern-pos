# Communication Service

**Version**: 1.0
**Last Updated**: November 4, 2025
**Status**: Production Specification

## Overview

The Communication Service handles real-time communication and notifications across the POS system, including kitchen display updates, receipt generation, and customer notifications via email/SMS. This service uses WebSocket for real-time updates and Redis pub/sub for event routing.

**Technology**: Go 1.24+, Redis 7+, WebSocket, ConnectRPC, SendGrid/AWS SES, Twilio/AWS SNS

## Responsibilities

- **Kitchen Display**: Real-time order updates via WebSocket
- **Receipt Generation**: Format and print receipts (mock adapter for MVP)
- **Email Notifications**: Customer receipts, order confirmations
- **SMS Notifications**: Order ready alerts, customer notifications
- **Event Routing**: Redis pub/sub for cross-service events
- **WebSocket Management**: Connection lifecycle, heartbeat, reconnection

**Does NOT handle**:
- Sales transactions (Order Fulfillment Service)
- Payment processing (Payment Service)
- User authentication (Platform Service validates JWT)

## Domain Entities

### KitchenOrder
Kitchen display representation of a sale
- Order number
- Items with modifiers
- Order type (dine-in, takeout, delivery)
- Status (pending, preparing, ready, completed)
- Timing information
- Station assignment (grill, fryer, etc.)

### Receipt
Formatted receipt for printing or email
- Sale details
- Items with prices
- Tax breakdown
- Payment method
- Footer (store info, thank you message)

### Notification
Email or SMS notification record
- Type (receipt, order_ready, alert)
- Recipient (email or phone)
- Content
- Status (pending, sent, failed)
- Delivery timestamp

### WebSocketConnection
Active WebSocket connection
- Connection ID
- Client type (kitchen, pos, admin)
- Location ID
- Last heartbeat
- Subscriptions (channels)

## API Endpoints (ConnectRPC)

```protobuf
service CommunicationService {
  // Kitchen Display
  rpc GetKitchenOrders(GetKitchenOrdersRequest) returns (GetKitchenOrdersResponse);
  rpc UpdateOrderStatus(UpdateOrderStatusRequest) returns (google.protobuf.Empty);
  
  // Receipts
  rpc PrintReceipt(PrintReceiptRequest) returns (google.protobuf.Empty);
  rpc EmailReceipt(EmailReceiptRequest) returns (google.protobuf.Empty);
  
  // Notifications
  rpc SendEmail(SendEmailRequest) returns (SendEmailResponse);
  rpc SendSMS(SendSMSRequest) returns (SendSMSResponse);
  rpc GetNotificationHistory(GetNotificationHistoryRequest) returns (GetNotificationHistoryResponse);
  
  // WebSocket (HTTP upgrade, not gRPC)
  // GET /ws?token=<jwt>
}
```

## Database Schema

```sql
-- Kitchen orders (cache of active orders)
CREATE TABLE kitchen_orders (
    id UUID PRIMARY KEY,
    sale_id UUID NOT NULL,
    order_number VARCHAR(50) NOT NULL,
    location_id UUID NOT NULL,
    items JSONB NOT NULL,  -- Denormalized for fast kitchen display
    order_type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'preparing', 'ready', 'completed', 'cancelled')),
    station VARCHAR(50),  -- 'grill', 'fryer', 'assembly', etc.
    priority INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX idx_kitchen_orders_location ON kitchen_orders(location_id);
CREATE INDEX idx_kitchen_orders_status ON kitchen_orders(status);
CREATE INDEX idx_kitchen_orders_created ON kitchen_orders(created_at DESC);

-- Notifications (email/SMS history)
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    type VARCHAR(50) NOT NULL CHECK (type IN ('email', 'sms')),
    purpose VARCHAR(50) NOT NULL,  -- 'receipt', 'order_ready', 'alert'
    recipient VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    content TEXT NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'sent', 'failed')),
    error_message TEXT,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- Receipts (for reprinting)
CREATE TABLE receipts (
    id UUID PRIMARY KEY,
    sale_id UUID NOT NULL,
    content TEXT NOT NULL,  -- Formatted receipt text
    format VARCHAR(20) NOT NULL CHECK (format IN ('text', 'html', 'pdf')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_receipts_sale_id ON receipts(sale_id);
```

## Redis Data Structures

```
# Pub/Sub channels
sale.created          # New sale created
sale.completed        # Sale payment completed
sale.voided           # Sale voided
sale.refunded         # Sale refunded
kitchen.order.ready   # Order ready for pickup
stock.depleted        # Stock level changed

# WebSocket connection tracking (Redis Hash)
ws:connections:<conn_id> = {
  user_id: "...",
  location_id: "...",
  client_type: "kitchen",
  connected_at: "2025-11-03T10:00:00Z",
  last_heartbeat: "2025-11-03T10:15:30Z"
}

# Active kitchen orders (Redis Sorted Set for fast querying)
kitchen:orders:<location_id> = {
  score: timestamp,
  value: order_id
}
```

## Key Workflows

### 1. Kitchen Display Real-Time Update
1. Order Fulfillment Service publishes sale.completed event
2. Communication Service subscribes to Redis channel
3. Transform sale → kitchen_order format
4. Insert into kitchen_orders table
5. Broadcast to WebSocket clients (kitchen displays)
   - Filter by location_id
   - Send JSON message with order details
6. Kitchen displays update UI in real-time

### 2. WebSocket Connection Lifecycle
1. Client connects to /ws?token=<jwt>
2. Validate JWT with Platform Service public key
3. Extract user_id, location_id from claims
4. Create connection record in Redis
5. Subscribe to relevant channels (based on location)
6. Send heartbeat ping every 30 seconds
7. On pong: update last_heartbeat timestamp
8. On disconnect: remove from Redis, close subscriptions

### 3. Print Receipt (Mock Adapter)
1. Receive PrintReceiptRequest (sale_id)
2. Fetch sale details from Order Fulfillment Service
3. Format receipt (items, totals, tax, payment)
4. Call ReceiptPrinterPort interface
5. MockReceiptPrinterAdapter logs to console:
   ```
   ========== RECEIPT ==========
   Store: ABC Restaurant
   Order: POS-2025-001234
   
   1x Kung Pao Chicken    $13.95
      + Large             $2.00
      + Extra Spicy       $0.00
   
   Subtotal:              $15.95
   Tax (8.75%):           $1.40
   Total:                 $17.35
   
   Payment: Cash
   Tendered:              $20.00
   Change:                $2.65
   ============================
   ```
6. Store receipt in receipts table (for reprinting)
7. Return success

### 4. Email Receipt
1. Receive EmailReceiptRequest (sale_id, email)
2. Fetch sale from Order Fulfillment Service
3. Format HTML email with receipt
4. Call EmailAdapterPort interface
5. SendGridEmailAdapter sends via SendGrid API
6. Create notification record (status: pending)
7. On SendGrid webhook: update status to sent/failed
8. Return email sent confirmation

### 5. Update Kitchen Order Status
1. Kitchen staff clicks "Ready" button
2. Frontend calls UpdateOrderStatus RPC
3. Update kitchen_orders.status = 'ready'
4. Publish kitchen.order.ready event
5. Broadcast to WebSocket clients:
   - POS terminals (show "Order Ready" notification)
   - Customer displays (show order number)
6. Optional: Send SMS to customer

### 6. Handle Offline Mode Receipt
1. POS offline: cannot connect to Communication Service
2. Generate receipt locally in browser
3. Show receipt modal with print button
4. Log: "Offline receipt for sale POS-OFFLINE-123"
5. When online: sync sale to server
6. Server regenerates receipt and stores in receipts table

---

**Back to**: [Design Document](../design/DESIGN_DOCUMENT.md)
