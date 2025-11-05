# Modern POS - Design Document

**Version**: 1.0
**Last Updated**: November 4, 2025
**Status**: Master Design Overview

---

## 1. Fundamental Requirements

### Business Context
The Modern POS system is designed specifically for **Quick Service Restaurants (QSR) and Fast Food** establishments, focusing on:
- High-volume transaction processing
- Quick order turnaround times
- Kitchen order management
- Multi-location support
- Offline resilience for uninterrupted service

### Core Functionality
- **Item Management**: Products, categories (n-deep hierarchy), modifiers with inheritance
- **Sales Processing**: Fast checkout, split payments, parked orders, kitchen tickets
- **Inventory**: Real-time stock tracking, transfers, low-stock alerts
- **Customer Management**: Portal access, purchase history, loyalty tracking
- **Reporting**: Real-time analytics, end-of-day reports, performance metrics

### MVP Scope
**Phase 1 (Core)**:
- User authentication and authorization (JWT-based)
- Item catalog with categories and modifiers
- Sales processing (POS checkout)
- Payment processing (cash, card)
- Basic stock management

**Phase 2 (Enhancement)**:
- Kitchen order management with display system
- Customer portal and accounts
- Advanced reporting and analytics
- Multi-location support

**Phase 3 (Scale)**:
- Third-party integrations (Xero, Google)
- Advanced offline capabilities
- Real-time synchronization across devices

---

## 2. Non-Functional Requirements

### Performance Requirements
- **Response Time**: API endpoints < 200ms (95th percentile)
- **Throughput**: Support 100+ concurrent sales transactions
- **Database**: Query response < 50ms for cached data
- **Real-Time Events**: WebSocket latency < 100ms
- **Offline Mode**: Full POS functionality without internet

### Security Requirements
- **Authentication**: RS256 JWT tokens (1h access, 7d refresh)
- **Authorization**: Role-based access control (RBAC)
- **Data Protection**: HTTPS/TLS 1.3, encryption at rest
- **PCI Compliance**: No raw card data stored (tokenized only)
- **CSRF Protection**: Double submit cookie pattern
- **Rate Limiting**: 1000 req/hour per user, 100 req/min per IP
- **Input Validation**: All inputs sanitized and validated server-side
- **Audit Logging**: All sensitive operations logged with user/IP/timestamp
- **Token Revocation**: Version-based instant revocation
- **Webhook Security**: Signature verification (HMAC)

### Scalability Requirements
- **Horizontal Scaling**: Stateless services (except Redis sessions)
- **Database**: Read replicas, connection pooling
- **Caching**: Redis for frequently accessed data
- **Load Balancing**: Round-robin across service instances
- **Auto-Scaling**: Based on CPU/memory metrics

### Offline Resilience
- **Local Caching**: Items, categories, modifiers, taxes stored in browser
- **Offline Queue**: Transactions queued and synced when online
- **Conflict Resolution**: Server-side validation on sync
- **Data Integrity**: Snapshot pricing at time of sale
- **Sync Window**: 24-hour maximum for offline transactions

---

## 3. Core Entities

### Item
Product or service available for sale (includes modifiers as non-sellable items).

### Category
Hierarchical menu organization with n-deep nesting and modifier inheritance.

### ModifierSection
Logical grouping of modifier groups for UI organization (e.g., "Customize", "Add-Ons").

### ModifierGroup
Defines customization options with selection rules (e.g., Size: required, single choice).

### ModifierOption
Individual choice within a modifier group, references an Item with pricing rules.

### Sale
Completed transaction with line items, payments, and financial totals.

### SaleItem
Line item in a sale with snapshot data (price, name, tax at time of sale).

### Payment
Payment record for a sale (cash, card, digital) with gateway transaction details.

### Customer
Customer information with portal access and purchase history.

### User
Staff/employee account with role-based permissions.

### Location
Store/warehouse location with settings (tax rate, timezone, currency).

### Device
POS terminal or kitchen display with registration and configuration.

### Stock
Inventory levels per item per location with reorder thresholds.

### Void
Void/refund record with reason, amount, and audit trail.

---

## 4. API Endpoints (ConnectRPC)

### Item Management Service (Port 8001)

**Items**:
- `GET /api/v1/items` - List items with filters
- `GET /api/v1/items/{id}` - Get item details
- `POST /api/v1/items` - Create item
- `PUT /api/v1/items/{id}` - Update item
- `DELETE /api/v1/items/{id}` - Delete item
- `GET /api/v1/items/{id}/modifiers` - Get item modifiers with inheritance

**Categories**:
- `GET /api/v1/categories` - List categories (tree structure)
- `POST /api/v1/categories` - Create category
- `PUT /api/v1/categories/{id}` - Update category
- `DELETE /api/v1/categories/{id}` - Delete category
- `GET /api/v1/categories/{id}/ancestors` - Get hierarchy path

**Modifiers**:
- `GET /api/v1/modifier-sections` - List modifier sections
- `GET /api/v1/modifier-groups` - List modifier groups
- `POST /api/v1/modifier-groups` - Create modifier group
- `PUT /api/v1/modifier-groups/{id}` - Update modifier group

**Stock**:
- `GET /api/v1/stock` - Get stock levels
- `PUT /api/v1/stock/{itemId}` - Update stock
- `POST /api/v1/stock/movements` - Record stock movement
- `POST /api/v1/stock/transfer` - Transfer between locations

### Order Fulfillment Service (Port 8002)

**Sales**:
- `POST /api/v1/sales` - Create sale
- `GET /api/v1/sales` - List sales with filters
- `GET /api/v1/sales/{ref}` - Get sale details
- `POST /api/v1/sales/{ref}/void` - Void sale
- `POST /api/v1/sales/{ref}/refund` - Refund sale

**Kitchen**:
- `GET /api/v1/kitchen/orders` - Get active kitchen orders
- `POST /api/v1/kitchen/orders/{ref}/acknowledge` - Acknowledge order
- `POST /api/v1/kitchen/orders/{ref}/complete` - Complete order

**Invoices**:
- `GET /api/v1/invoices` - List invoices
- `POST /api/v1/invoices` - Create invoice
- `GET /api/v1/invoices/{id}/generate` - Generate PDF
- `POST /api/v1/invoices/{id}/email` - Email invoice

### Communication Service (Port 8003)

**WebSocket**:
- `WS /ws` - Establish WebSocket connection
- `SSE /sse` - Server-Sent Events connection

**Events**:
- `POST /api/v1/events/subscribe` - Subscribe to event types
- `GET /api/v1/events/subscriptions` - Get current subscriptions

**Devices**:
- `POST /api/v1/devices/register` - Register device
- `POST /api/v1/devices/{id}/ping` - Heartbeat

### Payment Service (Port 8004)

**Payments**:
- `POST /api/v1/payments/process` - Process payment
- `POST /api/v1/payments/{id}/refund` - Refund payment
- `POST /api/v1/payments/split` - Split payment across methods

**Methods**:
- `GET /api/v1/payment-methods` - List payment methods
- `POST /api/v1/payment-methods` - Add payment method

### Supporting Service (Port 8005)

**Authentication**:
- `POST /api/v1/auth/login` - User login (issues JWT)
- `POST /api/v1/auth/refresh` - Refresh token
- `POST /api/v1/auth/logout` - End session
- `GET /.well-known/jwks.json` - JWT public keys

**Users**:
- `GET /api/v1/users` - List users
- `POST /api/v1/users` - Create user
- `PUT /api/v1/users/{id}` - Update user
- `PUT /api/v1/users/{id}/permissions` - Update permissions

**Customers**:
- `GET /api/v1/customers` - List customers
- `POST /api/v1/customers` - Create customer
- `GET /api/v1/customers/{id}/sales` - Purchase history

**Locations & Devices**:
- `GET /api/v1/locations` - List locations
- `POST /api/v1/locations` - Create location
- `GET /api/v1/devices` - List devices

**Reporting**:
- `GET /api/v1/reports/sales-summary` - Sales summary report
- `GET /api/v1/stats/general` - Dashboard statistics
- `GET /api/v1/graphs/takings` - Takings graph data

**Settings**:
- `GET /api/v1/settings` - Get all settings
- `PUT /api/v1/settings/general` - Update general settings

---

## 5. Dataflows

### Authentication Flow
1. Client sends credentials to Supporting Service
2. Supporting Service validates password (bcrypt)
3. Generates JWT tokens (RS256): access (1h) + refresh (7d)
4. Stores session in Redis
5. Returns tokens to client (access in memory, refresh in HttpOnly cookie)
6. Client includes JWT in Authorization header for all requests
7. Core services validate JWT using public key (no auth state)

### Sale Transaction Flow
1. Client builds cart (items, quantities, modifiers)
2. Client requests Item Management for pricing validation
3. Client initiates payment via Payment Service
4. Payment Service calls gateway (Stripe/Tyro), records transaction
5. Client submits sale to Order Fulfillment Service
6. Order Fulfillment validates totals, creates sale record (transaction)
7. Publishes `sale.completed` event via Communication Service
8. Item Management Service consumes event, updates stock
9. All connected devices receive real-time update via WebSocket
10. Client generates receipt, clears cart

### Kitchen Order Flow
1. Sale completed with type "eat-in" or "takeaway"
2. Order Fulfillment publishes `kitchen.order.new` event
3. Communication Service broadcasts to kitchen displays
4. Kitchen staff acknowledges order (status: preparing)
5. Kitchen completes order (status: ready)
6. POS terminals notified via WebSocket event

### Offline Sale Flow
1. Network connection lost detected
2. Client enters offline mode (displays indicator)
3. Client processes sale locally using cached data
4. Sale stored in offline queue (localStorage) with temp ref
5. Network restored detected
6. Client syncs offline sales to Order Fulfillment Service
7. Server validates totals, item existence, timestamps
8. Server assigns real refs, processes normally
9. Client updates local records, clears offline queue

### Real-Time Event Broadcasting
1. Service publishes event to Communication Service (HTTP POST)
2. Communication Service receives event, queries subscribers (Redis)
3. Filters devices by subscription patterns and location
4. Broadcasts to WebSocket connections via Redis Pub/Sub
5. Clients receive event, update UI, refresh local cache

---

## 6. High Level Design

### Architecture Pattern
**Hexagonal Architecture (Ports & Adapters)**:
- **Domain Layer**: Business logic, entities, use cases (no external dependencies)
- **Ports**: Interfaces defining contracts (inbound: use cases, outbound: repositories, gateways)
- **Adapters**: Concrete implementations (primary: HTTP handlers, secondary: PostgreSQL repos, Redis cache, Stripe gateway)
- **Dependency Injection**: Manual wiring or Google Wire for compile-time DI

### Service Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    API Gateway (Traefik)                │
│              Routes: /items, /sales, /auth              │
└──────────┬────────────────┬────────────────┬───────────┘
           │                │                │
           ▼                ▼                ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────┐
│ Item Management  │ │    Order     │ │   Payment    │
│    Service       │ │  Fulfillment │ │   Service    │
│   (Port 8001)    │ │ (Port 8002)  │ │ (Port 8004)  │
└────────┬─────────┘ └──────┬───────┘ └──────┬───────┘
         │                  │                 │
         │                  │                 │
         ▼                  ▼                 ▼
┌────────────────────────────────────────────────────────┐
│            Communication Service (Port 8003)           │
│         WebSocket, SSE, Redis Pub/Sub, Events          │
└────────────────────────┬───────────────────────────────┘
                         │
                         ▼
                ┌────────────────┐
                │   Supporting   │
                │    Service     │
                │  (Port 8005)   │
                │   Auth, Users, │
                │    Settings    │
                └────────────────┘
```

### Technology Stack

**Backend**:
- Language: Go 1.22+
- HTTP: Standard library (net/http with pattern matching)
- Database: PostgreSQL 15+ with SQLC (type-safe queries)
- Cache: Redis 7+ (sessions, pub/sub, device registry)
- Authentication: JWT RS256 (asymmetric signing)
- WebSocket: gorilla/websocket or nhooyr.io/websocket
- Logging: Structured (zerolog or zap)
- Metrics: Prometheus

**Frontend**:
- Framework: React 18+ with TypeScript
- State: Zustand or Redux Toolkit
- UI: Tailwind CSS + shadcn/ui
- Build: Vite
- WebSocket: Native WebSocket API
- Offline: Service Workers + IndexedDB

**Infrastructure**:
- Containerization: Docker
- Orchestration: Kubernetes (prod), Docker Compose (dev)
- API Gateway: Traefik or Nginx
- Monitoring: Prometheus + Grafana
- Logging: Loki + Grafana
- Tracing: Jaeger or Tempo

---

## 7. Database Design

### Item Management Service Database (item_management_db)

**Tables**:
- `items` - Product catalog with SKU, name, price, category
- `categories` - Hierarchical categories (parent_id for nesting)
- `modifier_sections` - Logical groupings of modifier groups
- `modifier_groups` - Customization groups with selection rules
- `modifier_options` - Individual modifier choices (references items)
- `suppliers` - Supplier information
- `tax_rules` - Tax rates and applicability
- `tax_items` - Compound tax components
- `stock` - Inventory levels per item per location
- `stock_movements` - Audit trail for inventory changes

### Order Fulfillment Service Database (order_fulfillment_db)

**Tables**:
- `sales` - Transaction records with totals and status
- `sale_items` - Line items with snapshot pricing
- `sale_payments` - Payment references (Payment Service owns actual records)
- `invoices` - Customer invoices for accounts receivable
- `invoice_items` - Invoice line items
- `invoice_payments` - Invoice payment tracking
- `parked_orders` - Saved orders for later completion
- `voids` - Void records with reason and audit
- `refunds` - Refund records (full or partial)

### Payment Service Database (payment_db)

**Tables**:
- `payments` - Payment transaction records
- `payment_methods` - Configured payment methods (cash, card, etc.)
- `payment_transactions` - Gateway transaction details
- `payment_gateway_logs` - Raw gateway responses for debugging
- `payment_refunds` - Refund transaction records

### Supporting Service Database (supporting_db)

**Tables**:
- `users` - Staff accounts with password hashes
- `user_permissions` - Permission assignments
- `user_sessions` - Active sessions (mirrored in Redis)
- `customers` - Customer accounts
- `customer_contacts` - Additional customer contact persons
- `customer_portal_access` - Portal login credentials
- `locations` - Store locations with settings
- `devices` - POS terminals and kitchen displays
- `device_registrations` - Pending device approvals
- `settings` - System-wide configuration
- `audit_logs` - Audit trail for sensitive operations
- `system_logs` - Application logs
- `integrations` - Third-party integration configs
- `integration_tokens` - OAuth tokens for integrations

### Communication Service Storage (Redis)

**Keys** (in-memory only, no PostgreSQL):
- `devices:online` - Hash of connected devices
- `subscriptions:{deviceId}` - Set of event subscriptions
- `sessions:{userId}` - User session data
- `events:*` - Pub/Sub channels for event broadcasting

---

## Document Metadata

**Version**: 1.0
**Created**: 2025-11-03
**Status**: Master Design Overview
**Source Documents**:
- ENTITIES.md (Core Entities)
- API_ENDPOINTS.md (API Endpoints)
- DATAFLOWS.md (Dataflows)
- HIGH_LEVEL_DESIGN.md (Architecture)
- MICROSERVICES.md (Service Design)
- SECURITY_REVIEW.md (Non-Functional Requirements)

**Next Steps**:
1. Review and approve design
2. Begin Phase 1 implementation (Supporting Service)
3. Implement Item Management Service
4. Build Order Fulfillment Service
5. Deploy Communication and Payment Services
6. Develop frontend POS application
7. Integration testing and security audit