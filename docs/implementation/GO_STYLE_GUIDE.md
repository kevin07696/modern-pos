# Go Style Guide - Modern POS

**Version**: 1.0
**Last Updated**: November 4, 2025
**Status**: Mandatory for All Go Code

---

## Overview

This guide defines coding standards, naming conventions, and best practices for all Go code in the Modern POS project. Following these conventions ensures consistency, readability, and maintainability.

**Philosophy**: Write code that is clear, idiomatic, and easy to maintain.

---

## Table of Contents

1. [Project Structure](#1-project-structure)
2. [Naming Conventions](#2-naming-conventions)
3. [File Organization](#3-file-organization)
4. [Package Design](#4-package-design)
5. [Error Handling](#5-error-handling)
6. [Testing](#6-testing)
7. [Documentation](#7-documentation)
8. [Code Organization](#8-code-organization)
9. [Dependency Injection](#9-dependency-injection)
10. [Common Patterns](#10-common-patterns)

---

## 1. Project Structure

### Service Structure (Hexagonal Architecture)

```
services/item-management/
├── cmd/
│   └── server/
│       └── main.go              # Entry point
├── internal/
│   ├── domain/                  # Business logic (hexagon core)
│   │   ├── item.go              # Domain entity
│   │   ├── item_service.go      # Business logic
│   │   ├── item_service_test.go
│   │   └── errors.go            # Domain errors
│   ├── ports/                   # Interfaces (hexagon ports)
│   │   ├── item_repository.go   # Port interface
│   │   └── event_publisher.go   # Port interface
│   └── adapters/                # Implementations (hexagon adapters)
│       ├── postgres/
│       │   ├── item_repository.go
│       │   └── item_repository_test.go
│       ├── redis/
│       │   └── event_publisher.go
│       └── grpc/
│           ├── item_handler.go
│           └── item_handler_test.go
├── pkg/                         # Public packages (if reusable)
│   └── middleware/
│       └── auth.go
├── migrations/                  # Database migrations
│   ├── 001_create_items.sql
│   └── 002_add_modifiers.sql
├── gen/                         # Generated code (from protos)
│   └── item/v1/
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

**Rules**:
- `cmd/` - Application entry points only
- `internal/` - Private code (cannot be imported by other projects)
- `pkg/` - Public, reusable packages
- `domain/` - Pure business logic (no external dependencies)
- `ports/` - Interface definitions
- `adapters/` - External integrations

---

## 2. Naming Conventions

### Files

```bash
# ✅ CORRECT - snake_case
item_service.go
item_repository.go
postgres_item_repository.go
item_service_test.go

# ❌ WRONG - camelCase or PascalCase
itemService.go
ItemRepository.go
```

**Rules**:
- All lowercase with underscores
- Test files: `*_test.go`
- Main files: `main.go` (in cmd/server/)

---

### Packages

```go
// ✅ CORRECT - short, lowercase, singular
package item
package postgres
package grpc

// ❌ WRONG - plural, underscores, or PascalCase
package items
package item_service
package ItemService
```

**Rules**:
- Short, lowercase, no underscores
- Singular (not plural): `item` not `items`
- Descriptive but concise

---

### Variables

```go
// ✅ CORRECT - camelCase
var itemCount int
var maxRetries int
var userID string

// ✅ Exported (public)
var DefaultTimeout = 30 * time.Second

// ❌ WRONG - snake_case or unclear abbreviations
var item_count int
var max_r int
var usrId string
```

**Rules**:
- camelCase for unexported (private)
- PascalCase for exported (public)
- Use full words, avoid abbreviations except:
  - `ID` (not Id or id)
  - `URL` (not Url)
  - `HTTP` (not Http)
  - `UUID` (not Uuid)
  - `DB` (database)
  - `SQL` (not Sql)

---

### Functions and Methods

```go
// ✅ CORRECT - PascalCase for exported
func CreateSale(req *CreateSaleRequest) (*Sale, error) {}

// ✅ CORRECT - camelCase for unexported
func calculateTotals(items []SaleItem) decimal.Decimal {}

// ✅ CORRECT - Get/Set prefix for getters/setters
func (s *Sale) GetTotal() decimal.Decimal {}
func (s *Sale) SetStatus(status SaleStatus) {}

// ❌ WRONG - snake_case
func create_sale() {}
func Calculate_Totals() {}
```

**Rules**:
- PascalCase for exported
- camelCase for unexported
- Verb-first naming: `CreateItem`, `GetUser`, `ValidateInput`
- Boolean getters: `IsActive()`, `HasPermission()`, `CanSync()`

---

### Constants

```go
// ✅ CORRECT - PascalCase (even for unexported)
const MaxRetries = 5
const DefaultTimeout = 30 * time.Second

// ✅ CORRECT - Grouped with type
const (
    StatusPending   SaleStatus = "pending"
    StatusCompleted SaleStatus = "completed"
    StatusVoided    SaleStatus = "voided"
)

// ❌ WRONG - ALL_CAPS (not Go style)
const MAX_RETRIES = 5
const DEFAULT_TIMEOUT = 30
```

**Rules**:
- PascalCase (not ALL_CAPS)
- Group related constants
- Use typed constants when possible

---

### Interfaces

```go
// ✅ CORRECT - "-er" suffix for single-method
type Reader interface {
    Read(p []byte) (n int, err error)
}

type ItemRepository interface {
    Create(ctx context.Context, item *Item) error
    GetByID(ctx context.Context, id string) (*Item, error)
}

// ✅ CORRECT - Descriptive name for multi-method
type ItemService interface {
    CreateItem(ctx context.Context, req *CreateItemRequest) (*Item, error)
    UpdateItem(ctx context.Context, req *UpdateItemRequest) (*Item, error)
    DeleteItem(ctx context.Context, id string) error
}

// ❌ WRONG - "I" prefix (not Go style)
type IItemRepository interface {}
```

**Rules**:
- "-er" suffix for single-method interfaces
- Descriptive name for multi-method
- No "I" prefix (that's Java/C# style)

---

### Struct Types

```go
// ✅ CORRECT - PascalCase, singular
type Item struct {
    ID    string
    Name  string
    Price decimal.Decimal
}

type SaleItem struct {
    SaleID   string
    ItemID   string
    Quantity int
}

// ❌ WRONG - plural or unclear
type Items struct {}
type Saleitem struct {}
```

**Rules**:
- PascalCase for exported
- Singular (not plural)
- Clear, descriptive names

---

## 3. File Organization

### Import Grouping

```go
package item

import (
    // 1. Standard library (alphabetical)
    "context"
    "fmt"
    "time"

    // 2. Third-party packages (alphabetical)
    "github.com/google/uuid"
    "github.com/shopspring/decimal"

    // 3. Local packages (alphabetical)
    "github.com/yourorg/pos/gen/item/v1"
    "github.com/yourorg/pos/internal/domain"
    "github.com/yourorg/pos/internal/ports"
)
```

**Rules**:
- Three groups: stdlib, third-party, local
- Blank line between groups
- Alphabetical within each group
- Use `goimports` to auto-format

---

### File Content Order

```go
package item

import (...)

// 1. Constants
const (
    MaxItemsPerSale = 1000
    DefaultTaxRate  = 0.08
)

// 2. Variables
var (
    ErrItemNotFound = errors.New("item not found")
)

// 3. Types
type Item struct {
    ID    string
    Name  string
    Price decimal.Decimal
}

type ItemService struct {
    repo      ports.ItemRepository
    publisher ports.EventPublisher
}

// 4. Constructor
func NewItemService(repo ports.ItemRepository, pub ports.EventPublisher) *ItemService {
    return &ItemService{
        repo:      repo,
        publisher: pub,
    }
}

// 5. Methods (grouped by receiver)
func (s *ItemService) CreateItem(ctx context.Context, req *CreateItemRequest) (*Item, error) {
    // ...
}

func (s *ItemService) GetItem(ctx context.Context, id string) (*Item, error) {
    // ...
}

// 6. Helper functions (unexported)
func calculateTax(subtotal decimal.Decimal, rate decimal.Decimal) decimal.Decimal {
    // ...
}
```

**Order**: Constants → Variables → Types → Constructors → Methods → Helpers

---

## 4. Package Design

### Domain Package (Pure Business Logic)

```go
// ✅ CORRECT - No external dependencies
package domain

import (
    "context"
    "errors"
    "time"

    "github.com/shopspring/decimal"
)

// Domain entity
type Sale struct {
    ID        string
    Items     []SaleItem
    Total     decimal.Decimal
    Status    SaleStatus
    CreatedAt time.Time
}

// Domain service (depends ONLY on ports)
type SaleService struct {
    saleRepo  ports.SaleRepository  // Interface, not concrete type
    itemRepo  ports.ItemRepository
    publisher ports.EventPublisher
}

// ❌ WRONG - Domain depending on concrete adapters
import "github.com/yourorg/pos/internal/adapters/postgres"
```

**Rules**:
- Domain depends ONLY on ports (interfaces)
- No database, HTTP, or external dependencies
- Pure business logic

---

### Ports Package (Interfaces)

```go
// ✅ CORRECT - Interface definitions only
package ports

import (
    "context"
    "github.com/yourorg/pos/internal/domain"
)

type ItemRepository interface {
    Create(ctx context.Context, item *domain.Item) error
    GetByID(ctx context.Context, id string) (*domain.Item, error)
    Update(ctx context.Context, item *domain.Item) error
    Delete(ctx context.Context, id string) error
    List(ctx context.Context, filter *ItemFilter) ([]*domain.Item, error)
}

type EventPublisher interface {
    PublishItemCreated(ctx context.Context, item *domain.Item) error
    PublishItemUpdated(ctx context.Context, item *domain.Item) error
}
```

**Rules**:
- Interface definitions only
- No implementations
- Grouped by responsibility

---

### Adapters Package (Implementations)

```go
// ✅ CORRECT - Implements port interface
package postgres

import (
    "context"
    "database/sql"

    "github.com/yourorg/pos/internal/domain"
    "github.com/yourorg/pos/internal/ports"
)

// Ensure interface compliance at compile time
var _ ports.ItemRepository = (*ItemRepository)(nil)

type ItemRepository struct {
    db *sql.DB
}

func NewItemRepository(db *sql.DB) *ItemRepository {
    return &ItemRepository{db: db}
}

func (r *ItemRepository) Create(ctx context.Context, item *domain.Item) error {
    query := `INSERT INTO items (id, name, price) VALUES ($1, $2, $3)`
    _, err := r.db.ExecContext(ctx, query, item.ID, item.Name, item.Price)
    return err
}
```

**Rules**:
- Each adapter in its own package
- Verify interface compliance: `var _ ports.Interface = (*Type)(nil)`
- Constructor returns concrete type

---

## 5. Error Handling

### Domain Errors

```go
// ✅ CORRECT - Sentinel errors for domain
package domain

import "errors"

var (
    ErrItemNotFound      = errors.New("item not found")
    ErrInvalidQuantity   = errors.New("quantity must be positive")
    ErrInsufficientStock = errors.New("insufficient stock")
)

// ✅ CORRECT - Custom error types for context
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}
```

### Error Wrapping

```go
// ✅ CORRECT - Wrap errors with context
func (s *SaleService) CreateSale(ctx context.Context, req *CreateSaleRequest) (*Sale, error) {
    sale, err := s.buildSale(req)
    if err != nil {
        return nil, fmt.Errorf("failed to build sale: %w", err)
    }

    if err := s.repo.Create(ctx, sale); err != nil {
        return nil, fmt.Errorf("failed to save sale: %w", err)
    }

    return sale, nil
}

// ❌ WRONG - Losing error context
func (s *SaleService) CreateSale(ctx context.Context, req *CreateSaleRequest) (*Sale, error) {
    sale, err := s.buildSale(req)
    if err != nil {
        return nil, err  // No context added
    }
    return sale, nil
}
```

**Rules**:
- Use `%w` to wrap errors: `fmt.Errorf("context: %w", err)`
- Add context at each layer
- Check with `errors.Is()` or `errors.As()`

---

## 6. Testing

### Test File Naming

```bash
# ✅ CORRECT
item_service_test.go
postgres_repository_test.go

# ❌ WRONG
item_test.go  # Ambiguous - what aspect of item?
test_item_service.go
```

### Table-Driven Tests

```go
// ✅ CORRECT - Table-driven tests
func TestCalculateTax(t *testing.T) {
    tests := []struct {
        name     string
        subtotal string
        rate     string
        want     string
    }{
        {
            name:     "8.75% tax on $100",
            subtotal: "100.00",
            rate:     "0.0875",
            want:     "8.75",
        },
        {
            name:     "zero tax rate",
            subtotal: "100.00",
            rate:     "0",
            want:     "0.00",
        },
        {
            name:     "high precision",
            subtotal: "123.45",
            rate:     "0.08675",
            want:     "10.71",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            subtotal := decimal.RequireFromString(tt.subtotal)
            rate := decimal.RequireFromString(tt.rate)
            want := decimal.RequireFromString(tt.want)

            got := calculateTax(subtotal, rate)

            if !got.Equal(want) {
                t.Errorf("calculateTax() = %v, want %v", got, want)
            }
        })
    }
}
```

### Test Helpers

```go
// ✅ CORRECT - Helper functions with t.Helper()
func createTestItem(t *testing.T, name string, price string) *Item {
    t.Helper()  // Marks this as helper - errors report caller's line

    return &Item{
        ID:    uuid.New().String(),
        Name:  name,
        Price: decimal.RequireFromString(price),
    }
}

func assertNoError(t *testing.T, err error) {
    t.Helper()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}
```

---

## 7. Documentation

### Package Documentation

```go
// ✅ CORRECT - Package doc comment
// Package domain implements core business logic for the POS system.
//
// This package contains entities, value objects, and domain services.
// It has no dependencies on external packages or infrastructure.
package domain
```

### Function Documentation

```go
// ✅ CORRECT - Complete function doc
// CreateSale creates a new sale with the given items and processes payment.
// It validates items, calculates totals including tax, and persists the sale.
//
// Returns an error if:
//   - Any item is not found
//   - Total calculation fails
//   - Database persistence fails
func (s *SaleService) CreateSale(ctx context.Context, req *CreateSaleRequest) (*Sale, error) {
    // ...
}

// ❌ WRONG - No documentation
func (s *SaleService) CreateSale(ctx context.Context, req *CreateSaleRequest) (*Sale, error) {
    // ...
}
```

**Rules**:
- Start with function/type name
- Explain what it does
- Document error conditions
- Use `//` (not `/* */`)

---

## 8. Code Organization

### Method Receivers

```go
// ✅ CORRECT - Pointer receiver (can modify, more efficient)
func (s *SaleService) CreateSale(ctx context.Context, req *CreateSaleRequest) (*Sale, error) {
    s.metrics.Inc("sales_created")  // Can modify state
    // ...
}

// ✅ CORRECT - Value receiver (small, immutable types)
func (m Money) String() string {
    return fmt.Sprintf("$%.2f", float64(m.Amount)/100)
}

// ❌ WRONG - Inconsistent receivers on same type
func (s *SaleService) CreateSale() {}   // Pointer
func (s SaleService) GetSale() {}       // Value - inconsistent!
```

**Rules**:
- Use pointer receivers by default
- Value receivers only for small, immutable types
- **Be consistent** - same type should use same receiver style

---

### Context as First Parameter

```go
// ✅ CORRECT - ctx as first parameter
func (s *SaleService) CreateSale(ctx context.Context, req *CreateSaleRequest) (*Sale, error) {
    // ...
}

// ❌ WRONG - ctx not first
func (s *SaleService) CreateSale(req *CreateSaleRequest, ctx context.Context) (*Sale, error) {
    // ...
}
```

---

## 9. Dependency Injection

### Constructor Pattern

```go
// ✅ CORRECT - Constructor with all dependencies
func NewSaleService(
    saleRepo ports.SaleRepository,
    itemRepo ports.ItemRepository,
    publisher ports.EventPublisher,
) *SaleService {
    return &SaleService{
        saleRepo:  saleRepo,
        itemRepo:  itemRepo,
        publisher: publisher,
    }
}

// ✅ CORRECT - Functional options for optional params
type SaleServiceOption func(*SaleService)

func WithMetrics(metrics *prometheus.Registry) SaleServiceOption {
    return func(s *SaleService) {
        s.metrics = metrics
    }
}

func NewSaleService(
    saleRepo ports.SaleRepository,
    opts ...SaleServiceOption,
) *SaleService {
    s := &SaleService{
        saleRepo: saleRepo,
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

---

## 10. Common Patterns

### Repository Pattern

```go
type SaleRepository interface {
    // Create - Returns error if ID already exists
    Create(ctx context.Context, sale *Sale) error

    // GetByID - Returns ErrSaleNotFound if not found
    GetByID(ctx context.Context, id string) (*Sale, error)

    // Update - Returns ErrSaleNotFound if not found
    Update(ctx context.Context, sale *Sale) error

    // Delete - Returns ErrSaleNotFound if not found
    Delete(ctx context.Context, id string) error

    // List - Returns empty slice if no results
    List(ctx context.Context, filter *SaleFilter) ([]*Sale, error)

    // Exists - Returns true if sale exists
    Exists(ctx context.Context, id string) (bool, error)
}
```

### Service Pattern

```go
type SaleService struct {
    // Dependencies (all interfaces)
    saleRepo  ports.SaleRepository
    itemRepo  ports.ItemRepository
    publisher ports.EventPublisher

    // Optional dependencies
    logger  *slog.Logger
    metrics *prometheus.Registry
}

// Business logic methods
func (s *SaleService) CreateSale(ctx context.Context, req *CreateSaleRequest) (*Sale, error) {
    // 1. Validate input
    // 2. Fetch dependencies
    // 3. Execute business logic
    // 4. Persist changes
    // 5. Publish events
    // 6. Return result
}
```

---

## Code Quality Checklist

### Before Committing

- [ ] `go fmt ./...` - Format code
- [ ] `go vet ./...` - Check for issues
- [ ] `golangci-lint run` - Lint code
- [ ] `staticcheck ./...` - Static analysis
- [ ] `go test ./...` - All tests pass
- [ ] `go build ./...` - Code compiles
- [ ] All exported functions have doc comments
- [ ] No TODO comments in production code

### Tools Configuration

```bash
# Install required tools
go install golang.org/x/tools/cmd/goimports@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

---

## References

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)
- [Standard Go Project Layout](https://github.com/golang-standards/project-layout)

---

**Enforcement**: This guide is mandatory for all Go code. PRs will be rejected if they don't follow these conventions.
