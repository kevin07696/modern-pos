# Item Management Service

**Version**: 1.0
**Last Updated**: November 4, 2025
**Status**: Production Specification

## Overview

The Item Management Service manages the restaurant's menu catalog, including items, categories, modifiers, and inventory tracking. This service is the source of truth for all sellable products and their configurations.

**Technology**: Go 1.24+, PostgreSQL 15+, ConnectRPC, SQLC, Goose

## Responsibilities

- **Menu Management**: Items, categories (n-level hierarchy), pricing
- **Modifier System**: Modifier sections, groups, and options for item customization
- **Inventory Tracking**: Stock levels and movements across locations
- **Supplier Management**: Supplier information and purchase orders
- **Multi-language Support**: Localized item names and descriptions

**Does NOT handle**:
- Tax calculation (handled by Platform Service at location level)
- Sales transactions (handled by Order Fulfillment Service)
- Pricing history/auditing (MVP scope)

## Domain Entities

### Item
Sellable product (e.g., "Kung Pao Chicken", "Large Pizza")
- SKU, name, description, price
- Category assignment
- Modifier sections
- Sellable/stockable flags

### Category
Hierarchical menu organization (n-level tree)
- Parent-child relationships
- Display order and icons
- Supports unlimited nesting

### ModifierSection
Groups related modifier options (e.g., "Size", "Toppings")
- Contains multiple modifier groups
- Ordered presentation

### ModifierGroup
Set of selectable options (e.g., "Small/Medium/Large")
- Selection rules (min/max, required)
- Price adjustments
- Availability restrictions

### ModifierOption
Individual choice within a group
- References an Item
- Price adjustment (+$2.00, -$1.00, free)
- Stock tracking (optional)

### Stock
Current inventory levels per item per location
- Quantity, unit of measure
- Reorder levels
- Last counted timestamp

### StockMovement
Audit trail for inventory changes
- Type (sale, adjustment, transfer, waste)
- Quantity change
- Reason and reference

### Supplier
Vendor information for purchase orders
- Contact details
- Payment terms
- Active status

## API Endpoints (ConnectRPC)

```protobuf
service ItemManagementService {
  // Items
  rpc CreateItem(CreateItemRequest) returns (Item);
  rpc UpdateItem(UpdateItemRequest) returns (Item);
  rpc GetItem(GetItemRequest) returns (Item);
  rpc ListItems(ListItemsRequest) returns (ListItemsResponse);
  rpc DeleteItem(DeleteItemRequest) returns (google.protobuf.Empty);

  // Categories
  rpc CreateCategory(CreateCategoryRequest) returns (Category);
  rpc UpdateCategory(UpdateCategoryRequest) returns (Category);
  rpc GetCategory(GetCategoryRequest) returns (Category);
  rpc ListCategories(ListCategoriesRequest) returns (ListCategoriesResponse);
  rpc DeleteCategory(DeleteCategoryRequest) returns (google.protobuf.Empty);

  // Modifiers
  rpc CreateModifierSection(CreateModifierSectionRequest) returns (ModifierSection);
  rpc UpdateModifierSection(UpdateModifierSectionRequest) returns (ModifierSection);
  rpc GetModifierSection(GetModifierSectionRequest) returns (ModifierSection);
  rpc ListModifierSections(ListModifierSectionsRequest) returns (ListModifierSectionsResponse);

  rpc CreateModifierGroup(CreateModifierGroupRequest) returns (ModifierGroup);
  rpc UpdateModifierGroup(UpdateModifierGroupRequest) returns (ModifierGroup);
  rpc GetModifierGroup(GetModifierGroupRequest) returns (ModifierGroup);

  // Stock
  rpc UpdateStock(UpdateStockRequest) returns (Stock);
  rpc GetStock(GetStockRequest) returns (Stock);
  rpc ListStock(ListStockRequest) returns (ListStockResponse);
  rpc RecordStockMovement(RecordStockMovementRequest) returns (StockMovement);
  rpc GetStockMovements(GetStockMovementsRequest) returns (GetStockMovementsResponse);

  // Suppliers
  rpc CreateSupplier(CreateSupplierRequest) returns (Supplier);
  rpc UpdateSupplier(UpdateSupplierRequest) returns (Supplier);
  rpc ListSuppliers(ListSuppliersRequest) returns (ListSuppliersResponse);
}
```

## Database Schema

```sql
-- Items
CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku VARCHAR(100) UNIQUE NOT NULL,
    name JSONB NOT NULL,
    description JSONB DEFAULT '{}',
    price DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    sellable BOOLEAN DEFAULT true,
    stockable BOOLEAN DEFAULT true,
    modifier_sections UUID[] DEFAULT '{}',
    image_url TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_items_category ON items(category_id);
CREATE INDEX idx_items_sku ON items(sku);
CREATE INDEX idx_items_sellable ON items(sellable) WHERE sellable = true;

-- Categories (n-level hierarchy)
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name JSONB NOT NULL,
    description JSONB DEFAULT '{}',
    parent_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    display_order INT DEFAULT 0,
    icon_url TEXT,
    color VARCHAR(7),
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_categories_parent ON categories(parent_id);

-- Stock
CREATE TABLE stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    location_id UUID NOT NULL,
    quantity DECIMAL(12,3) DEFAULT 0,
    reorder_level DECIMAL(12,3) DEFAULT 0,
    reorder_qty DECIMAL(12,3) DEFAULT 0,
    uom VARCHAR(20) DEFAULT 'ea',
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(item_id, location_id)
);

-- Stock movements (audit trail)
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id),
    location_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL,
    quantity DECIMAL(12,3) NOT NULL,
    reason TEXT,
    user_id UUID NOT NULL,
    reference VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Modifier sections
CREATE TABLE modifier_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name JSONB NOT NULL,
    description JSONB DEFAULT '{}',
    min_selection INT DEFAULT 0,
    max_selection INT DEFAULT 1,
    required BOOLEAN DEFAULT false,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Modifier groups
CREATE TABLE modifier_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID NOT NULL REFERENCES modifier_sections(id) ON DELETE CASCADE,
    name JSONB NOT NULL,
    display_order INT DEFAULT 0,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Modifier options
CREATE TABLE modifier_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES modifier_groups(id) ON DELETE CASCADE,
    name JSONB NOT NULL,
    price_adjustment DECIMAL(12,2) DEFAULT 0,
    display_order INT DEFAULT 0,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Suppliers
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    payment_terms TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Key Workflows

### 1. Create Item with Modifiers
1. Validate item data (SKU, price, category)
2. Create item record
3. Assign modifier sections
4. Create initial stock record (if stockable)
5. Publish item.created event

### 2. Update Stock Levels
1. Validate location and item
2. Calculate new quantity
3. Create stock movement record (audit)
4. Update stock table
5. Check reorder levels
6. Publish stock.updated event

### 3. Process Sale (Stock Depletion)
1. Subscribe to sale.completed event
2. For each stockable item: deduct quantity
3. Record SALE stock movement
4. Check low stock alerts

### 4. Get Items with Categories
1. Query items by filter
2. Join with categories
3. Include modifiers (if requested)
4. Apply localization
5. Return paginated results

---

**Next**: [Order Fulfillment Service](ORDER_FULFILLMENT_SERVICE.md)
