# Future Entity Fields Reference

**Version**: 1.0
**Last Updated**: November 4, 2025
**Purpose**: Fields to add in Sprint 2-4 (not in Sprint 1 MVP)

---

## Overview

This document lists additional fields that will be added to entities in future sprints. The Sprint 1 MVP has simplified schemas - these fields represent the complete production system.

---

## Item Entity

### Current (Sprint 1 MVP)

```protobuf
message Item {
  string id = 1;
  string sku = 2;
  common.v1.LocalizedString name = 3;
  common.v1.LocalizedString description = 4;
  common.v1.Money price = 5;
  string category_id = 6;
  bool sellable = 7;
  bool stockable = 8;
  repeated string modifier_section_ids = 9;
  string image_url = 10;
  bool active = 11;
}
```

### Future Fields (Sprint 2-4)

```protobuf
message Item {
  // ... existing fields ...

  // Sprint 2: Cost and Profit Tracking
  common.v1.Money cost = 20;  // Cost of goods (for profit calculation)

  // Sprint 2: Marketing and Display
  bool is_popular = 21;   // Featured/popular item badge
  bool is_new = 22;       // New item badge
  bool is_spicy = 23;     // Spicy indicator
  repeated string tags = 24;  // Searchable tags ("vegetarian", "gluten-free")

  // Sprint 3: Nutritional Information
  int32 calories = 30;    // Calorie count
  repeated DietaryTag dietary_tags = 31;  // VEGAN, GLUTEN_FREE, etc.
  repeated Allergen allergens = 32;  // PEANUTS, SHELLFISH, etc.

  // Sprint 3: Kitchen Prep (from backlog)
  int32 prep_time_minutes = 33;  // Estimated prep time

  // Sprint 3: Time-Based Availability
  Availability availability = 40;

  // Sprint 4: Multi-Image Support
  repeated string image_urls = 50;  // Multiple product images (vs single image_url)

  // Sprint 4: Supplier Information
  string supplier_id = 60;

  // Audit (already present)
  google.protobuf.Timestamp created_at = 12;
  google.protobuf.Timestamp updated_at = 13;
}

enum DietaryTag {
  DIETARY_TAG_UNSPECIFIED = 0;
  DIETARY_TAG_VEGAN = 1;
  DIETARY_TAG_VEGETARIAN = 2;
  DIETARY_TAG_GLUTEN_FREE = 3;
  DIETARY_TAG_DAIRY_FREE = 4;
  DIETARY_TAG_NUT_FREE = 5;
  DIETARY_TAG_LOW_CARB = 6;
  DIETARY_TAG_KETO = 7;
}

enum Allergen {
  ALLERGEN_UNSPECIFIED = 0;
  ALLERGEN_PEANUTS = 1;
  ALLERGEN_TREE_NUTS = 2;
  ALLERGEN_SHELLFISH = 3;
  ALLERGEN_FISH = 4;
  ALLERGEN_EGGS = 5;
  ALLERGEN_DAIRY = 6;
  ALLERGEN_SOY = 7;
  ALLERGEN_WHEAT = 8;
  ALLERGEN_SESAME = 9;
}

message Availability {
  repeated int32 days_of_week = 1;  // 0=Sunday, 6=Saturday
  string start_time = 2;  // "11:00:00"
  string end_time = 3;    // "22:00:00"
  google.protobuf.Timestamp valid_from = 4;  // Seasonal items
  google.protobuf.Timestamp valid_until = 5;
}
```

---

## SaleItem Entity

### Current (Sprint 1 MVP)

```protobuf
message SaleItem {
  string id = 1;
  string sale_id = 2;
  string item_id = 3;
  string name = 4;
  double quantity = 6;
  common.v1.Money unit_price = 7;
  common.v1.Percentage tax_rate = 8;  // Snapshot
  common.v1.Money tax_amount = 9;
  common.v1.Money total = 10;
  repeated AppliedModifier modifiers = 11;
}
```

### Future Fields (Sprint 3-4)

```protobuf
message SaleItem {
  // ... existing fields ...

  // Sprint 3: Kitchen Prep (from backlog)
  int32 prep_time_minutes = 20;  // Snapshot from Item at time of sale

  // Sprint 4: Cost Tracking
  common.v1.Money cost = 30;  // Snapshot for profit calculation

  // Sprint 4: Kitchen Status
  SaleItemStatus kitchen_status = 40;
  google.protobuf.Timestamp preparing_started_at = 41;
  google.protobuf.Timestamp ready_at = 42;
}

enum SaleItemStatus {
  SALE_ITEM_STATUS_UNSPECIFIED = 0;
  SALE_ITEM_STATUS_PENDING = 1;
  SALE_ITEM_STATUS_PREPARING = 2;
  SALE_ITEM_STATUS_READY = 3;
  SALE_ITEM_STATUS_SERVED = 4;
}
```

---

## User Entity

### Current (Sprint 1 MVP)

```protobuf
message User {
  string id = 1;
  string username = 2;
  string name = 3;
  bool admin = 4;
  repeated string permissions = 5;
  string location_id = 6;
  bool disabled = 7;
}
```

### Future Fields (Sprint 4)

```protobuf
message User {
  // ... existing fields ...

  // Sprint 4: Enhanced Authentication
  string email = 20;
  string phone = 21;
  int32 token_version = 22;  // For instant token revocation

  // Sprint 4: Role-Based Access Control
  repeated string roles = 30;  // CASHIER, MANAGER, ADMIN

  // Sprint 4: Employee Management
  string employee_id = 40;
  string department = 41;
  google.protobuf.Timestamp hired_date = 42;

  // Sprint 4: PIN for quick login
  string pin_hash = 50;  // 4-6 digit PIN (hashed)

  // Audit
  google.protobuf.Timestamp created_at = 11;
  google.protobuf.Timestamp last_login = 12;
}
```

---

## Location Entity

### Current (Sprint 1 MVP)

```protobuf
message Location {
  string id = 1;
  string name = 2;
  common.v1.Percentage tax_rate = 3;
  string timezone = 4;
  string currency_code = 5;
}
```

### Future Fields (Sprint 4)

```protobuf
message Location {
  // ... existing fields ...

  // Sprint 4: Full Address
  string address_line1 = 20;
  string address_line2 = 21;
  string city = 22;
  string state = 23;
  string postal_code = 24;
  string country = 25;

  // Sprint 4: Contact Information
  string phone = 30;
  string email = 31;

  // Sprint 4: Business Hours
  message BusinessHours {
    string day_of_week = 1;  // MONDAY, TUESDAY, etc.
    string open_time = 2;     // "09:00:00"
    string close_time = 3;    // "22:00:00"
    bool closed = 4;          // Closed on this day
  }
  repeated BusinessHours business_hours = 40;

  // Sprint 4: Settings
  bool enable_tipping = 50;
  repeated common.v1.Percentage suggested_tip_percentages = 51;
  int32 receipt_printer_timeout_seconds = 52;
}
```

---

## Customer Entity

### Current (Sprint 1 MVP - Not Implemented)

```protobuf
// Not in Sprint 1
```

### Future (Sprint 3-4)

```protobuf
message Customer {
  string id = 1;
  string name = 2;
  string email = 3;
  string phone = 4;

  // Sprint 3: Loyalty Program
  int32 loyalty_points = 10;
  string loyalty_tier = 11;  // BRONZE, SILVER, GOLD

  // Sprint 4: Customer Portal
  bool portal_activated = 20;
  google.protobuf.Timestamp last_portal_login = 21;

  // Sprint 4: Marketing Preferences
  bool email_opt_in = 30;
  bool sms_opt_in = 31;

  // Audit
  google.protobuf.Timestamp created_at = 40;
  google.protobuf.Timestamp updated_at = 41;
}
```

---

## Payment Entity

### Current (Sprint 1 MVP - Cash Only)

```protobuf
message Payment {
  string id = 1;
  string sale_id = 2;
  PaymentMethod method = 3;  // CASH only in Sprint 1
  common.v1.Money amount = 4;
  PaymentStatus status = 5;
}
```

### Future Fields (Sprint 2-3)

```protobuf
message Payment {
  // ... existing fields ...

  // Sprint 2: Card Payment Details
  string card_type = 20;        // VISA, MASTERCARD, AMEX
  string last4 = 21;             // Last 4 digits
  string approval_code = 22;
  string gateway_transaction_id = 23;

  // Sprint 2: Digital Wallet
  string digital_wallet_type = 30;  // APPLE_PAY, GOOGLE_PAY

  // Sprint 3: Split Payments
  string transaction_group_id = 40;  // Groups multiple payments for one sale

  // Sprint 3: Refunds
  string refund_of_payment_id = 50;  // If this payment is a refund

  // Audit
  google.protobuf.Timestamp processed_at = 60;
}
```

---

## Stock Entity

### Current (Sprint 1 - Not Implemented)

```protobuf
// Not in Sprint 1
```

### Future (Sprint 4)

```protobuf
message Stock {
  string id = 1;
  string item_id = 2;
  string location_id = 3;
  double quantity = 4;
  string unit = 5;  // "ea", "kg", "lb", "oz"
  double reorder_point = 6;
  double reorder_quantity = 7;
  google.protobuf.Timestamp last_counted_at = 8;
  google.protobuf.Timestamp created_at = 9;
  google.protobuf.Timestamp updated_at = 10;
}

message StockMovement {
  string id = 1;
  string item_id = 2;
  string location_id = 3;
  MovementType type = 4;  // PURCHASE, SALE, ADJUSTMENT, TRANSFER
  double quantity = 5;
  string unit = 6;
  string reference_id = 7;  // Sale ID, PO ID, etc.
  string notes = 8;
  google.protobuf.Timestamp created_at = 9;
}
```

---

## Migration Strategy

### Sprint 2
1. Add cost, marketing fields to Item
2. Add card payment fields to Payment
3. Update proto task files

### Sprint 3
1. Add nutritional, availability fields to Item
2. Add prep_time to Item and SaleItem (from backlog)
3. Add split payment support to Payment
4. Create Customer entity

### Sprint 4
1. Add multi-image support to Item
2. Add RBAC fields to User
3. Create Stock and StockMovement entities
4. Add business hours to Location

---

## Proto File Organization

```
proto/
├── common/v1/           # Shared types
├── item/v1/             # Sprint 1 MVP complete
│   └── item_service.proto
├── item/v2/             # Sprint 2-4 additions
│   └── item_service.proto  # Add advanced fields
├── order/v1/            # Sprint 1 MVP complete
│   └── order_service.proto
└── stock/v1/            # Sprint 4 new
    └── stock_service.proto
```

---

**Next**: Reference this document when creating Sprint 2-4 task files for entity enhancements.
