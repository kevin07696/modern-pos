# Order Fulfillment Service

**Version**: 1.0
**Last Updated**: November 4, 2025
**Status**: Production Specification

## Overview

The Order Fulfillment Service manages the complete sales transaction lifecycle, from order creation through payment processing to completion. This service handles both online and offline transactions with automatic synchronization.

**Technology**: Go 1.24+, PostgreSQL 15+, ConnectRPC, SQLC, Goose

## Responsibilities

- **Sales Management**: Create, update, void, and refund sales
- **Payment Processing**: Cash and card payments, split payments
- **Tax Calculation**: Apply location-based tax rates (snapshot pattern)
- **Offline Sync**: Handle backdated transactions with idempotency
- **Order Lifecycle**: Pending → Completed → Voided/Refunded states
- **Payment Integration**: Coordinate with external Payment Service

**Does NOT handle**:
- Item pricing (from Item Management Service)
- Tax rates (from Platform Service - snapshot at sale time)
- Kitchen display (Communication Service handles via events)
- Receipt printing (Communication Service handles via events)

## Domain Entities

### Sale
Complete transaction record
- UUID (internal primary key, used for offline sync idempotency)
- Display number (customer-facing: #1, #2, #3... resets daily per location)
- Type (sale, order, invoice)
- Status (pending, completed, voided, refunded)
- Financial totals (subtotal, tax, discount, total)
- Context (customer, user, device, location)
- Timestamps (created, processed)

### SaleItem
Line item in a sale
- Item snapshot (name, price at time of sale)
- Quantity and pricing
- Tax rate snapshot (preserves historical accuracy)
- Applied modifiers (JSON array)
- Notes

### Payment
Payment record for a sale
- Method (cash, card, digital)
- Amount paid
- Transaction details (card last4, approval code)
- Status

### Void
Void/refund record
- Type (void, refund)
- Reason
- Amount
- Partial refund items
- Authorization (user, device)

### ParkedOrder
Temporarily saved order
- Order reference
- Item snapshot (JSONB)
- Financial totals
- Resume status

## API Endpoints (ConnectRPC)

```protobuf
service OrderFulfillmentService {
  // Sales
  rpc CreateSale(CreateSaleRequest) returns (Sale);
  rpc GetSale(GetSaleRequest) returns (Sale);
  rpc ListSales(ListSalesRequest) returns (ListSalesResponse);
  rpc UpdateSale(UpdateSaleRequest) returns (Sale);
  
  // Payments
  rpc ProcessPayment(ProcessPaymentRequest) returns (ProcessPaymentResponse);
  rpc ProcessSplitPayment(ProcessSplitPaymentRequest) returns (ProcessSplitPaymentResponse);
  
  // Voids/Refunds
  rpc VoidSale(VoidSaleRequest) returns (VoidSaleResponse);
  rpc RefundSale(RefundSaleRequest) returns (RefundSaleResponse);
  
  // Parked Orders
  rpc ParkOrder(ParkOrderRequest) returns (ParkedOrder);
  rpc GetParkedOrder(GetParkedOrderRequest) returns (ParkedOrder);
  rpc ResumeParkedOrder(ResumeParkedOrderRequest) returns (Sale);
  rpc ListParkedOrders(ListParkedOrdersRequest) returns (ListParkedOrdersResponse);
  
  // Offline Sync
  rpc SyncOfflineSales(SyncOfflineSalesRequest) returns (SyncOfflineSalesResponse);
  
  // Reports
  rpc GetSaleHistory(GetSaleHistoryRequest) returns (GetSaleHistoryResponse);
  rpc GetSalesSummary(GetSalesSummaryRequest) returns (SalesSummary);
}
```

## Database Schema

```sql
-- Sales
CREATE TABLE sales (
    id UUID PRIMARY KEY,
    display_number INT NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('sale', 'order', 'invoice')),
    status VARCHAR(30) NOT NULL CHECK (status IN ('pending', 'completed', 'voided', 'refunded', 'partially_refunded')),
    
    -- Financial
    subtotal DECIMAL(12,2) NOT NULL,
    discount DECIMAL(12,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(12,2) NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    
    -- Context
    customer_id UUID,
    user_id UUID NOT NULL,
    device_id UUID NOT NULL,
    location_id UUID NOT NULL,
    
    -- Metadata
    notes TEXT,
    table_number INTEGER,
    order_type VARCHAR(20) CHECK (order_type IN ('dine_in', 'takeout', 'delivery', 'online')),
    
    -- Audit
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_sales_display_number_daily ON sales(location_id, display_number, DATE(created_at));
CREATE INDEX idx_sales_location_id ON sales(location_id);
CREATE INDEX idx_sales_user_id ON sales(user_id);
CREATE INDEX idx_sales_status ON sales(status);
CREATE INDEX idx_sales_created_at ON sales(created_at DESC);

-- Sale items
CREATE TABLE sale_items (
    id UUID PRIMARY KEY,
    sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    item_id UUID NOT NULL,
    
    -- Snapshot (preserves historical data)
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Quantity & Pricing
    quantity DECIMAL(10,3) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    tax_rate DECIMAL(5,4) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    
    -- Modifiers (JSON array)
    modifiers JSONB DEFAULT '[]'::jsonb,
    
    -- Metadata
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX idx_sale_items_item_id ON sale_items(item_id);

-- Payments
CREATE TABLE sale_payments (
    id UUID PRIMARY KEY,
    sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    transaction_group_id VARCHAR(100) NOT NULL,
    
    -- Payment info
    method VARCHAR(20) NOT NULL CHECK (method IN ('cash', 'card', 'digital', 'check', 'store_credit')),
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    
    -- Card-specific
    card_type VARCHAR(50),
    last4 VARCHAR(4),
    approval_code VARCHAR(50),
    
    -- Audit
    processed_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sale_payments_sale_id ON sale_payments(sale_id);
CREATE INDEX idx_sale_payments_txn_group ON sale_payments(transaction_group_id);

-- Voids/Refunds
CREATE TABLE voids (
    id UUID PRIMARY KEY,
    sale_id UUID NOT NULL REFERENCES sales(id),
    type VARCHAR(20) NOT NULL CHECK (type IN ('void', 'refund')),
    reason TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    
    -- For partial refunds
    items JSONB,
    
    -- Context
    user_id UUID NOT NULL,
    device_id UUID NOT NULL,
    refund_txn_id VARCHAR(100),
    
    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_voids_sale_id ON voids(sale_id);
CREATE INDEX idx_voids_created_at ON voids(created_at DESC);

-- Parked orders
CREATE TABLE parked_orders (
    id UUID PRIMARY KEY,
    order_ref VARCHAR(50) UNIQUE NOT NULL,
    
    -- Sale snapshot (JSON)
    items JSONB NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    
    -- Context
    user_id UUID NOT NULL,
    device_id UUID NOT NULL,
    location_id UUID NOT NULL,
    table_number INTEGER,
    notes TEXT,
    
    -- Status
    resumed BOOLEAN NOT NULL DEFAULT false,
    resumed_at TIMESTAMPTZ,
    resumed_by_id UUID,
    
    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_parked_orders_location ON parked_orders(location_id);
CREATE INDEX idx_parked_orders_resumed ON parked_orders(resumed);
```

## Key Workflows

### 1. Create Sale with Tax Calculation
1. Receive CreateSaleRequest with items
2. Fetch item details from Item Management Service
3. Fetch tax rate from Platform Service (by location)
4. Calculate line totals with modifiers
5. Apply tax rate (snapshot in sale_items)
6. Calculate sale totals
7. Create sale record (status: pending)
8. Create sale_items records
9. Return sale

### 2. Process Payment (Cash)
1. Validate sale exists and is pending
2. Validate payment amount >= total
3. Calculate change (if cash)
4. Create sale_payment record
5. Update sale status to completed
6. Publish sale.completed event
7. Return payment confirmation

### 3. Process Payment (Card via Payment Service)
1. Validate sale
2. Create transaction group ID
3. Call PaymentService.ProcessPayment (ConnectRPC)
4. Subscribe to payment.completed event
5. On success: create sale_payment, update sale status
6. On failure: handle error, allow retry
7. Return payment result

### 4. Handle Offline Sale Sync

1. Receive batch of offline sales (with pre-generated UUIDs)
2. For each sale:
   - Check idempotency (UUID exists in database?)
   - If exists: return existing sale (skip - already synced)
   - If new: validate, create sale + items + payments
3. Mark stock.depleted for each item
4. Return sync results (created, skipped, errors)

### 5. Process Refund
1. Validate sale is completed
2. Validate refund amount <= original total
3. If card payment: call PaymentService.RefundPayment
4. Create void record
5. Update sale status to refunded/partially_refunded
6. Create stock.returned movements (for refunded items)
7. Publish sale.refunded event
8. Return refund confirmation

---

**Next**: [Platform Service](PLATFORM_SERVICE.md)
