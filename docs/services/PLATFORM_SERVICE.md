# Platform Service

**Version**: 1.0
**Last Updated**: November 4, 2025
**Status**: Production Specification

## Overview

The Platform Service provides foundational infrastructure for the entire POS system, including authentication, user management, location/tax configuration, and system-wide settings. This service is the first to be deployed and acts as the foundation for all other services.

**Technology**: Go 1.24+, PostgreSQL 15+, ConnectRPC, SQLC, Goose, JWT (RS256)

## Responsibilities

- **Authentication**: JWT token generation and validation (RS256 asymmetric signing)
- **User Management**: Users, roles, permissions, sessions
- **Customer Management**: Customer records for receipts and loyalty
- **Location Management**: Store locations with tax configuration
- **Device Management**: POS terminals, kitchen displays, admin consoles
- **Tax Configuration**: Location-level tax rates (snapshot pattern for sales)
- **System Settings**: Key-value configuration store
- **Audit Logging**: System-wide audit trail

**Does NOT handle**:
- Sales transactions (Order Fulfillment Service)
- Item management (Item Management Service)
- Payment processing (Payment Service)
- Kitchen display real-time updates (Communication Service)

## Domain Entities

### User
Staff/employee account
- Username, email, password (bcrypt)
- Role (admin, manager, cashier, kitchen)
- Permissions (JSONB)
- Assigned location
- Active status

### Customer
Customer information for receipts and CRM
- Email, name, phone
- Address (JSONB)
- Notes
- Optional password (customer portal)

### Location
Store/restaurant location
- Name, address
- Country code, timezone, currency
- Tax rate (simple, single rate per location)
- Receipt footer
- Active status

### Device
POS terminal or display
- Name, type (terminal, kitchen, admin)
- Assigned location
- Last seen timestamp
- Active status

### Session
JWT token tracking for revocation
- User ID
- Token ID (JWT "jti" claim)
- Refresh token hash
- Expiration, revoked status

### AuditLog
System-wide audit trail
- User, action, entity type/ID
- Details (JSONB)
- IP address, user agent
- Timestamp

## API Endpoints (ConnectRPC)

```protobuf
service PlatformService {
  // Authentication
  rpc Login(LoginRequest) returns (LoginResponse);
  rpc RefreshToken(RefreshTokenRequest) returns (RefreshTokenResponse);
  rpc Logout(LogoutRequest) returns (google.protobuf.Empty);
  rpc ValidateToken(ValidateTokenRequest) returns (ValidateTokenResponse);
  
  // Users
  rpc CreateUser(CreateUserRequest) returns (User);
  rpc UpdateUser(UpdateUserRequest) returns (User);
  rpc GetUser(GetUserRequest) returns (User);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
  rpc ChangePassword(ChangePasswordRequest) returns (google.protobuf.Empty);
  rpc UpdatePermissions(UpdatePermissionsRequest) returns (User);
  
  // Customers
  rpc CreateCustomer(CreateCustomerRequest) returns (Customer);
  rpc UpdateCustomer(UpdateCustomerRequest) returns (Customer);
  rpc GetCustomer(GetCustomerRequest) returns (Customer);
  rpc ListCustomers(ListCustomersRequest) returns (ListCustomersResponse);
  
  // Locations
  rpc CreateLocation(CreateLocationRequest) returns (Location);
  rpc UpdateLocation(UpdateLocationRequest) returns (Location);
  rpc GetLocation(GetLocationRequest) returns (Location);
  rpc ListLocations(ListLocationsRequest) returns (ListLocationsResponse);
  rpc GetTaxRate(GetTaxRateRequest) returns (GetTaxRateResponse);
  
  // Devices
  rpc RegisterDevice(RegisterDeviceRequest) returns (Device);
  rpc UpdateDevice(UpdateDeviceRequest) returns (Device);
  rpc GetDevice(GetDeviceRequest) returns (Device);
  rpc ListDevices(ListDevicesRequest) returns (ListDevicesResponse);
  rpc HeartbeatDevice(HeartbeatDeviceRequest) returns (google.protobuf.Empty);
  
  // Settings
  rpc GetSetting(GetSettingRequest) returns (Setting);
  rpc SetSetting(SetSettingRequest) returns (Setting);
  rpc ListSettings(ListSettingsRequest) returns (ListSettingsResponse);
  
  // Audit
  rpc RecordAuditLog(RecordAuditLogRequest) returns (google.protobuf.Empty);
  rpc GetAuditLogs(GetAuditLogsRequest) returns (GetAuditLogsResponse);
}
```

## Database Schema

```sql
-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'manager', 'cashier', 'kitchen')),
    permissions JSONB NOT NULL,
    location_id UUID NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_location_id ON users(location_id);
CREATE INDEX idx_users_role ON users(role);

-- Sessions (for JWT token revocation)
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_id VARCHAR(100) UNIQUE NOT NULL,  -- JWT "jti" claim
    refresh_token_hash VARCHAR(255) NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT false,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_token_id ON user_sessions(token_id);
CREATE INDEX idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_sessions_revoked ON user_sessions(revoked);

-- Customers
CREATE TABLE customers (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    mobile VARCHAR(50),
    address JSONB,
    notes TEXT,
    password_hash VARCHAR(255),  -- For customer portal access
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_name ON customers(name);

-- Locations
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    
    -- Address
    address TEXT,
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country_code CHAR(2) NOT NULL,  -- "US", "PH", "CA"
    
    -- Internationalization
    currency_code CHAR(3) NOT NULL DEFAULT 'USD',
    timezone VARCHAR(50) NOT NULL,  -- "America/New_York", "Asia/Manila"
    
    -- Tax configuration (simple, single rate)
    tax_rate NUMERIC(5,4) NOT NULL DEFAULT 0.00,  -- 0.0875 = 8.75%
    
    -- Receipt customization
    receipt_footer TEXT,
    
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT tax_rate_between_0_and_1 CHECK (tax_rate >= 0 AND tax_rate <= 1)
);

CREATE INDEX idx_locations_active ON locations(active);
CREATE INDEX idx_locations_country ON locations(country_code);

-- Devices
CREATE TABLE devices (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location_id UUID NOT NULL REFERENCES locations(id),
    type VARCHAR(30) NOT NULL CHECK (type IN ('terminal', 'kitchen', 'admin', 'customer_display')),
    last_seen_at TIMESTAMPTZ,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_devices_location_id ON devices(location_id);
CREATE INDEX idx_devices_type ON devices(type);

-- Settings (key-value configuration)
CREATE TABLE settings (
    key VARCHAR(255) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Audit logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY,
    user_id UUID,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID,
    details JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity_type ON audit_logs(entity_type);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
```

## Key Workflows

### 1. User Login (JWT Generation)
1. Receive LoginRequest (username, password)
2. Query user by username
3. Verify password with bcrypt
4. Generate access token (RS256, 1 hour expiry)
   - Claims: sub (user ID), username, role, permissions
   - Sign with private key (ONLY Platform Service has private key)
5. Generate refresh token (30 days)
6. Create session record
7. Return tokens

### 2. Token Validation (Other Services)
1. Receive JWT from request header
2. Validate signature with public key (distributed to all services)
3. Check expiration
4. Check token ID not revoked (optional: cache in Redis)
5. Extract claims (user ID, permissions)
6. Return validation result

### 3. Get Tax Rate for Sale
1. Receive GetTaxRateRequest (location_id)
2. Query locations table
3. Return tax_rate value
4. Order Service snapshots this value in sale_items

### 4. User Logout (Token Revocation)
1. Receive LogoutRequest (token_id from JWT claims)
2. Mark session as revoked
3. Other services check revocation on next request
4. Remove from cache (if cached)

### 5. Change Password
1. Validate old password
2. Hash new password (bcrypt cost 12)
3. Update user record
4. Revoke ALL user sessions (force re-login)
5. Return success

### 6. Device Heartbeat
1. Receive HeartbeatDeviceRequest (device_id)
2. Update last_seen_at timestamp
3. Services can check device health
4. Alert if device not seen > 5 minutes

---

**Next**: [Communication Service](COMMUNICATION_SERVICE.md)
