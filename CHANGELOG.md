# Changelog

All notable changes to the Modern POS project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - 2025-11-04

#### Sprint 2, 3, and 4 Task Files (48 stories)

Created comprehensive user story task files for all remaining sprints:

**Sprint 2 (Nov 11-15): Modifiers & Card Payments** - 16 stories created
- **S2.1-S2.4: Modifiers System**
  - S2.1: Proto Contract Enhancements for Modifiers (complete proto definitions)
  - S2.2: Implement Modifier Selection Logic (domain service with validation)
  - S2.3: Modifier CRUD API Implementation (ConnectRPC endpoints)
  - S2.4: Modifier Management UI (React components with TanStack Query)

- **S2.5-S2.8: Payment Integration**
  - S2.5: Payment Integration - Stripe Setup (complete integration guide)
  - S2.6: Card Payment API Implementation (payment service with adapter pattern)
  - S2.7: Webhook Handling for Payment Events (signature verification, idempotency)
  - S2.8: Card Payment UI (checkout flow with payment methods)

- **S2.9-S2.12: POS Terminal UI**
  - S2.9: Complete POS Terminal - Item Selection
  - S2.10: POS Terminal - Modifier Selection
  - S2.11: POS Terminal - Cart Management
  - S2.12: POS Terminal - Checkout Flow

- **S2.13-S2.16: Production Deployment**
  - S2.13: Docker Production Configuration
  - S2.14: CI/CD Pipeline Setup (GitHub Actions)
  - S2.15: Production Deployment to Cloud
  - S2.16: Sprint 2 Demo Preparation

**Sprint 3 (Nov 18-22): Offline Mode & Advanced Features** - 16 stories created
- **S3.1-S3.4: Offline Infrastructure**
  - S3.1: Offline Mode - IndexedDB Setup (complete schema with Dexie.js)
  - S3.2: Connectivity Detection and Status Management
  - S3.3: Local Storage for Catalog Data
  - S3.4: Offline Sync Queue Manager

- **S3.5-S3.8: Sync & Customer Management**
  - S3.5: Offline Sale Sync Endpoint (server-side validation)
  - S3.6: Server-Side Sync Validation (security checks)
  - S3.7: Customer Proto Contracts (loyalty, portal access)
  - S3.8: Customer Management UI

- **S3.9-S3.12: Split Payments & Refunds**
  - S3.9: Split Payment Proto Contracts
  - S3.10: Split Payment Backend Implementation
  - S3.11: Split Payment UI
  - S3.12: Refund System Implementation

- **S3.13-S3.16: Printer & Notifications**
  - S3.13: Receipt Printer Integration (ESC/POS commands)
  - S3.14: Receipt Template System
  - S3.15: Print Queue Management
  - S3.16: Push Notifications for Order Updates

**Sprint 4 (Nov 25-29): Production Readiness** - 16 stories created
- **S4.1-S4.4: User Management & RBAC**
  - S4.1: User Management Proto Contracts (roles, permissions)
  - S4.2: Role-Based Access Control System
  - S4.3: Enhanced Authentication (token versioning, PIN support)
  - S4.4: User Administration UI

- **S4.5-S4.8: Stock Tracking**
  - S4.5: Stock Tracking Proto Contracts
  - S4.6: Stock Movement Recording
  - S4.7: Low Stock Alerts
  - S4.8: Stock Management UI

- **S4.9-S4.12: Reports & Analytics**
  - S4.9: Sales Summary Report
  - S4.10: Item Performance Analytics
  - S4.11: Analytics Dashboard
  - S4.12: Report Export (PDF, CSV, Excel)

- **S4.13-S4.16: Final Production**
  - S4.13: Security Audit and Hardening
  - S4.14: Performance Optimization
  - S4.15: Monitoring and Alerting (Prometheus, Grafana)
  - S4.16: Production Launch Checklist

**Task File Quality**:
- Each file follows exact Sprint 1 format
- Comprehensive technical details with code examples
- Complete proto contracts, database schemas, API definitions
- Detailed acceptance criteria and testing plans
- Realistic story point estimates (1-13 Fibonacci)
- Proper inter-story dependencies documented
- References to service specifications and design docs

**Total Stories**: 64 stories (16 × 4 sprints)
**Story Points**: ~220 total points across all sprints
**Coverage**: Complete Modern POS implementation from infrastructure to production

**Files Created**:
- `docs/implementation/tasks/sprint-2/*.md` - 16 Sprint 2 task files
- `docs/implementation/tasks/sprint-3/*.md` - 16 Sprint 3 task files
- `docs/implementation/tasks/sprint-4/*.md` - 16 Sprint 4 task files

**Result**: Complete sprint backlog ready for GitHub Projects sync

#### Sprint Board Automation and Team Workflow

Created complete Jira-style sprint board system using GitHub Projects for team collaboration:

**SPRINT_BOARD_SETUP.md**: Comprehensive Jira-style team board guide
- GitHub Projects V2 configuration (Board, Table, Roadmap views)
- Sprint planning workflow (backlog, planning, standup, review, retro)
- Team collaboration features (assignments, comments, notifications)
- Velocity tracking and capacity planning
- Story point estimation (Planning Poker)
- Multiple board views (Sprint Board, Backlog, Team View, Roadmap)
- Automation rules for card movement
- Definition of Done checklist

**GITHUB_PROJECTS_SETUP.md**: Step-by-step setup guide (20 minutes)
- Repository creation and configuration
- Project board setup with custom fields
- Column configuration (Backlog → Ready → In Progress → Review → Done)
- Custom fields: Sprint, Story Points, Priority, Blocked
- 7 different views for different workflows
- Team member invitation and permissions
- Keyboard shortcuts and mobile access
- Troubleshooting guide

**SPRINT_PLANNING_TEMPLATE.md**: Reusable planning template
- Team capacity calculation worksheet
- Velocity history tracking
- Sprint backlog with story commitments
- Risk identification and mitigation
- Definition of Done checklist
- Sprint goal breakdown
- Sign-off and commitment process
- Example: Sprint 1 planning completed

**TEAM_WORKFLOW.md**: Daily workflow quick reference (print-friendly)
- Morning standup routine (15 min)
- Story picking and assignment
- Git workflow (branching, commits, PRs)
- Code review process
- Common scenarios (blocked, unclear requirements, bugs)
- Testing checklist
- Communication protocols
- Emergency contacts
- Useful commands reference

**PROJECT_MANAGEMENT.md**: Original automation guide
- GitHub Projects vs Linear vs Markdown board comparison
- Alternative platforms evaluated
- Setup time: ~30 minutes, fully automatable
- **Recommended**: GitHub Projects (native integration, free, CLI-driven)

**Automation Scripts** (`scripts/`):

1. **sync-tasks-to-github.sh**: Convert task markdown files to GitHub issues
   - Extracts metadata (Sprint, Story Points, Priority, Assignee)
   - Parses user stories and acceptance criteria
   - Creates issues with proper labels and assignments
   - Links back to task file in repository
   - Processes all sprints (sprint-1, sprint-2, sprint-3, sprint-4)

2. **update-sprint-board.sh**: Sync issues to GitHub Projects board
   - Queries open issues with sprint labels
   - Adds issues to project board automatically
   - Updates status based on labels
   - Handles large issue sets (1000+ limit)

3. **sprint-report.sh**: Generate sprint progress reports
   - Counts stories by status (pending, in progress, done)
   - Calculates completion percentage
   - Visual progress bar
   - Lists all open stories with assignees
   - Usage: `./sprint-report.sh [sprint_number]`

**Makefile Integration**: Claude-executable commands
- `make sync-tasks` - Sync all task files to GitHub issues
- `make update-board` - Update sprint board with latest status
- `make sprint-report` - Generate current sprint report
- `make sprint-report SPRINT=2` - Generate specific sprint report
- `make help` - Display all available commands

**GitHub Actions** (`.github/workflows/sync-sprint-board.yml`):
- Automatic sync when task files change (`docs/implementation/tasks/**/*.md`)
- Manual trigger via workflow_dispatch
- Permissions: issues write, projects write
- Runs sync-tasks and update-board scripts
- Zero configuration needed (uses repository secrets)

**Claude Integration**:
- All scripts executable via `make` commands
- Environment variables configurable (REPO_OWNER, REPO_NAME, PROJECT_NUMBER)
- Scripts designed for both manual and automated execution
- Daily workflow support (standup reports, issue tracking)

**Files Created**:
- `docs/implementation/SPRINT_BOARD_SETUP.md` - Jira-style team board comprehensive guide
- `docs/implementation/GITHUB_PROJECTS_SETUP.md` - Step-by-step GitHub Projects setup (20 min)
- `docs/implementation/SPRINT_PLANNING_TEMPLATE.md` - Reusable sprint planning template
- `docs/implementation/TEAM_WORKFLOW.md` - Daily workflow quick reference (print-friendly)
- `docs/implementation/PROJECT_MANAGEMENT.md` - Platform comparison and automation guide
- `scripts/sync-tasks-to-github.sh` - Task file → GitHub issue sync (executable)
- `scripts/update-sprint-board.sh` - Issue → Project board sync (executable)
- `scripts/sprint-report.sh` - Sprint progress reporting (executable)
- `Makefile` - Project management command interface
- `.github/workflows/sync-sprint-board.yml` - Automatic sync workflow

**Result**: Complete Jira-style sprint board system ready for team collaboration with GitHub Projects

#### Modern-POS Content Extraction

Extracted all critical content from `modern-pos/` to `docs/` before deletion:

**DELETION_REVIEW.md**: Comprehensive file-by-file analysis
- Analyzed 18 files from modern-pos (7,214 lines)
- Identified 12 duplicates/obsolete files
- Extracted critical content from 6 key files

**Critical Content Extracted**:

1. **docs/design/SECURITY.md** (from SECURITY_REVIEW.md)
   - 12 security issues with code-level fixes
   - Token revocation via versioning
   - CSRF protection patterns
   - Payment validation strategies
   - WebSocket authentication
   - Offline sale validation
   - Sprint 1-4 security checklist

2. **docs/implementation/OFFLINE_GUIDE.md** (from OFFLINE_TRANSACTION_HANDLING.md)
   - React hooks (useOnlineStatus, useBackendHealth, useConnectivity)
   - IndexedDB schema with Dexie
   - Offline transaction creation logic
   - Sync queue manager with retry
   - Server-side validation patterns
   - UI components for offline mode

3. **docs/implementation/FUTURE_FIELDS.md** (from ENTITIES.md)
   - Advanced fields for Sprint 2-4
   - Cost tracking, nutritional info, dietary tags
   - Multi-image support, prep time estimation
   - Customer loyalty, stock management
   - Migration strategy by sprint

**Content Distribution**:
- Security: 8 critical issues → SECURITY.md
- Offline: Complete implementation → OFFLINE_GUIDE.md
- Entities: Future fields reference → FUTURE_FIELDS.md
- Duplicate service specs: Already in docs/services/
- Obsolete REST API docs: Superseded by ConnectRPC

**Result**: All critical modern-pos content now in docs/, `modern-pos/` directory deleted

**Files Created**:
- `docs/design/SECURITY.md` - Production security requirements
- `docs/implementation/OFFLINE_GUIDE.md` - Sprint 3 offline mode implementation
- `docs/implementation/FUTURE_FIELDS.md` - Sprint 2-4 entity enhancements
- `docs/implementation/GO_STYLE_GUIDE.md` - Go coding standards and conventions

**Files Removed**:
- Temporary analysis files (COVERAGE_ANALYSIS.md, DELETION_REVIEW.md, STATUS.md)

#### Go Style Guide

Created comprehensive coding standards for all Go development:

**GO_STYLE_GUIDE.md**: Mandatory coding conventions
- Project structure (hexagonal architecture)
- Naming conventions (files, packages, variables, functions, constants, interfaces)
- File organization and import grouping
- Package design patterns (domain, ports, adapters)
- Error handling best practices
- Testing conventions (table-driven tests, helpers)
- Documentation standards
- Dependency injection patterns
- Code quality checklist

**Covers**: Project layout, naming, testing, documentation, common patterns
**Purpose**: Ensure consistency and maintainability across all Go services

#### Documentation Cleanup and Standardization

Cleaned up all markdown files in `docs/` directory for consistency and quality:

**Formatting Improvements**:
- ✅ Fixed markdown linting issues (blank lines around lists)
- ✅ Standardized "Last Updated" dates to November 4, 2025
- ✅ Verified all internal links work correctly
- ✅ Consistent date formatting across all documentation

**Files Updated**:
- All 4 service specifications (ITEM_MANAGEMENT, ORDER_FULFILLMENT, PLATFORM, COMMUNICATION)
- Design document (DESIGN_DOCUMENT.md)
- Main README.md
- Sprint plan and status documents

#### Documentation Coverage Analysis

Created comprehensive analysis verifying all content from `modern-pos/` is covered in `docs/`:

**COVERAGE_ANALYSIS.md**: File-by-file mapping of original design docs to cleaned-up documentation
- ✅ All critical content covered in `docs/` (services, implementation, design)
- ✅ Sprint 1-4 task directories created
- 📋 Optional reference material identified (ENTITIES.md, DATAFLOWS.md, SECURITY_REVIEW.md)
- 📋 Recommendations for future enhancements (sequence diagrams, detailed entity reference)

**Key Findings**:
- All 4 service specifications complete
- Sprint plan and task files comprehensive
- ConnectRPC setup fully documented
- Design document covers core concepts

**Status**: ✅ Documentation is complete and ready for Sprint 1 (Nov 4, 2025)

### Changed - 2025-11-04

#### Sale Numbering System: Simplified Dual Identifier Design

Removed redundant `sale_number` field and simplified to dual identifier system:

**Design Rationale**:
- **Problem**: Original design had 3 identifiers per sale (UUID, sale_number, display_number would be needed)
- **Root Cause**: Confused technical idempotency with customer-facing display
- **Solution**: Use UUID for idempotency, add display_number for customers

**Changes**:
- **Removed**: `sale_number` field (POS-2025-001234 / POS-OFFLINE-timestamp format)
- **Kept**: `id` (UUID) - serves as primary key AND offline sync idempotency key
- **Added**: `display_number` (int32) - customer-facing order number, resets daily per location (#1, #2, #3...)

**Why This is Better**:
1. **Eliminates offline/online inconsistency**: Customers always see same format (#123)
2. **Simpler idempotency**: Offline devices pre-generate UUIDs locally
3. **No format leakage**: Implementation details (offline vs online) don't leak to customers
4. **Cleaner database**: One less unique index, simpler schema

**Affected Files**:
- `docs/implementation/tasks/sprint-1/S1.6-proto-order-service.md`: Updated Sale message
- `docs/implementation/tasks/sprint-1/S1.9-create-sale-with-tax.md`: Added display_number generation logic
- `docs/implementation/tasks/sprint-1/S1.11-publish-sale-completed.md`: Updated event structure
- `docs/services/ORDER_FULFILLMENT_SERVICE.md`: Updated schema and workflows

**Receipt Example**:
```
========== RECEIPT ==========
Order #123          ← Customer-facing (always same format)
Store: ABC Restaurant

1x Kung Pao Chicken    $13.95
...
```

### Added - 2025-11-04

#### Sprint 3 Story: Intelligent Prep Time Estimation

Created future enhancement story for data-driven kitchen efficiency:

**S3.14-intelligent-prep-time.md**: Intelligent prep time estimation system
- Add `prep_time_minutes` field to items (with seed estimates)
- Snapshot prep time in sale_items
- Track actual prep times when orders move through kitchen workflow
- Nightly cron job analyzes historical data (30 days)
- Refines estimates using median calculation (robust to outliers)
- Transforms kitchen display from "time elapsed" to "estimated completion time"
- Color coding based on schedule adherence (not age)
- Machine learning foundation for future predictive features

**Design Philosophy**:
- Start simple: Manual seed estimates (e.g., Kung Pao Chicken = 15 min)
- Learn continuously: Track actual prep times in production
- Refine automatically: Nightly analysis updates estimates (>10% variance threshold)
- Use median: More robust than mean for outlier rejection

**Sprint 1 MVP**: Time elapsed urgency indicator (red = old, prioritize!)
**Sprint 3 Enhancement**: Intelligent completion time prediction with learning

Updated task files to reference future enhancement:
- S1.5 (Item proto): Note about future prep_time field
- S1.6 (Order proto): Note about SaleItem prep_time snapshot
- S1.14 (Kitchen Display): Clarified time elapsed vs. completion time

#### Sprint 1 Task Files Complete (16 stories)

Created all remaining Sprint 1 user story task files for implementation:

**Infrastructure Tasks** (`docs/implementation/tasks/sprint-1/`):
- **S1.2-configure-docker.md**: Docker Compose setup for PostgreSQL and Redis
- **S1.3-setup-buf.md**: Buf CLI configuration for proto code generation

**Proto Contract Definitions**:
- **S1.4-proto-common-types.md**: Common types (Money, LocalizedString, Percentage, Pagination)
- **S1.5-proto-item-service.md**: Item Management Service contracts (Items, Categories, Modifiers, Stock)
- **S1.6-proto-order-service.md**: Order Fulfillment Service contracts (Sales, Payments, Voids, Sync)
- **S1.7-proto-platform-service.md**: Platform Service contracts (Auth, Users, Locations, Tax)
- **S1.8-generate-proto-code.md**: Code generation validation and verification

**Backend Implementation Tasks**:
- **S1.10-process-cash-payment.md**: Cash payment processing with change calculation
- **S1.11-publish-sale-completed.md**: Redis pub/sub event publishing for sale completion

**Frontend Implementation Tasks**:
- **S1.12-item-list-component.md**: Item browsing with category filtering and search
- **S1.13-websocket-infrastructure.md**: Real-time WebSocket server and client infrastructure
- **S1.15-cash-payment-ui.md**: Cash payment UI with amount tendered and change display

**Demo & Testing**:
- **S1.16-demo-preparation.md**: End-to-end demo script, seed data, and polish

All Sprint 1 stories now include:
- Complete user story format (As a... I want... So that...)
- Detailed acceptance criteria with Given/When/Then scenarios
- Definition of Done checklists
- Technical implementation details with code examples
- Step-by-step implementation guides
- Testing strategies (unit, integration, manual)
- Time estimates and dependencies
- Related stories cross-references

**Status Update**:
- Sprint 1: 16 of 16 stories documented (100% complete)
- Total progress: 16 of 64 stories (25%)
- Ready to begin Sprint 1 implementation Monday, November 4, 2025

Updated documentation:
- `docs/STATUS.md`: Reflects Sprint 1 completion, updated task counts
- `docs/README.md`: References all Sprint 1 task files

### Added - 2025-11-03

#### Documentation Reorganization

Created production-ready documentation structure in `docs/` directory:

**Design Documentation** (`docs/design/`):
- **DESIGN_DOCUMENT.md**: Master design document with structured sections
  - Fundamental Requirements (business context, core functionality, MVP scope)
  - Non-Functional Requirements (performance, security, scalability, offline)
  - Core Entities (brief descriptions of all 13 entities)
  - API Endpoints (ConnectRPC organized by service)
  - Dataflows (key operational flows with sequence diagrams)
  - High Level Design (Ports & Adapters architecture, service diagram, tech stack)
  - Database Design (table summary by service)

**Service Documentation** (`docs/services/`):
- **ITEM_MANAGEMENT_SERVICE.md**: Menu catalog, modifiers, inventory
  - Service overview and responsibilities
  - Domain entities (Item, Category, ModifierSection, Stock)
  - ConnectRPC API endpoints
  - Complete database schema with indexes
  - Key workflows (Create item, Update stock, Process sale depletion)

- **ORDER_FULFILLMENT_SERVICE.md**: Sales transactions and payments
  - Service overview and responsibilities
  - Domain entities (Sale, SaleItem, Payment, Void)
  - ConnectRPC API endpoints
  - Complete database schema
  - Key workflows (Create sale with tax, Process payment, Offline sync, Refunds)

- **PLATFORM_SERVICE.md**: Authentication, users, locations, tax
  - Service overview and responsibilities
  - Domain entities (User, Customer, Location, Device, Session)
  - ConnectRPC API endpoints
  - JWT authentication with RS256
  - Complete database schema
  - Key workflows (Login/JWT generation, Token validation, Tax rate retrieval)

- **COMMUNICATION_SERVICE.md**: Kitchen display, receipts, notifications
  - Service overview and responsibilities
  - Domain entities (KitchenOrder, Receipt, Notification)
  - WebSocket and ConnectRPC endpoints
  - Database and Redis pub/sub schema
  - Key workflows (Real-time kitchen updates, Print receipt, Email/SMS)

**Implementation Documentation** (`docs/implementation/`):
- **SPRINT_PLAN.md**: High-level sprint overview and timeline
  - 4 sprints (Nov 4 - Nov 29, 2025)
  - Sprint goals and key deliverables
  - Story counts per sprint (16 stories each)
  - Daily rituals (standup, planning, review, retro)
  - Velocity and capacity planning
  - Definition of Ready and Definition of Done
  - Risk management

- **tasks/**: Individual agile user stories (64 total stories)
  - `sprint-1/`: S1.1 - S1.16 (Foundation, items, orders, kitchen display)
  - `sprint-2/`: S2.1 - S2.16 (Modifiers, card payments, POS UI, deployment)
  - `sprint-3/`: S3.1 - S3.16 (Offline mode, real printer, notifications)
  - `sprint-4/`: S4.1 - S4.16 (RBAC, stock, reports, monitoring)
  - Each story includes:
    - User story format (As a... I want... So that...)
    - Acceptance criteria (Given/When/Then)
    - Definition of Done checklist
    - Technical details and implementation steps
    - Testing strategy
    - Time estimates
    - Dependencies

**Example Task Files Created**:
- `tasks/sprint-1/S1.1-setup-monorepo.md`: Infrastructure setup example
- `tasks/sprint-1/S1.9-create-sale-with-tax.md`: Backend API example
- `tasks/sprint-1/S1.14-kitchen-display-ui.md`: Frontend UI example
- `tasks/README.md`: Task file format and guidelines

#### Original Documentation (preserved in `modern-pos/`)
- **SPRINT_PLAN.md**: Detailed 4-week implementation plan (~500 lines)
  - Executive summary with Quick Service/Fast Food focus
  - Restaurant type clarification (Type A & C in scope, Type B deferred)
  - Feature priority ranking (P0-P3) with 16 ranked features
  - Architecture decisions:
    - Simplified tax configuration (location-level, no history table)
    - International architecture strategy (US + Philippines support)
    - Receipt printer mock adapter pattern
    - Authentication strategy (simple JWT in Sprint 1, full RBAC in Sprint 4)
  - Detailed 4-week sprint breakdown:
    - Sprint 1: Core order flow (orders, kitchen display, cash payments)
    - Sprint 2: Modifiers, card payments, POS UI, production deployment
    - Sprint 3: Offline mode, split payments, customer notifications
    - Sprint 4: User management, stock tracking, reports, final deployment
  - Day-by-day task breakdown for each sprint (16 hours/day, 2 developers)
  - Parallel development strategy (~85% parallelization after Day 1)
  - Contract-first approach (define all protos on Day 1)
  - Testing strategy (unit, integration, E2E, load, manual)
  - Success criteria for each sprint
  - Risk mitigation strategies
  - Out-of-scope features deferred to future releases
  - Complete technology stack reference

- **PROJECT_STRUCTURE.md**: Complete monorepo directory structure and organization
  - Go workspace configuration with go.work and go.mod examples
  - Service architecture showing domain/ports/adapters separation
  - Complete Makefile with proto generation, SQLC, migrations, build, and test commands
  - Docker Compose configuration for local development (PostgreSQL, Redis)
  - Service entry point example (cmd/item-management/main.go) with:
    - Database and Redis initialization
    - Adapter instantiation patterns
    - Domain service creation
    - ConnectRPC handler setup
    - HTTP/2 server with h2c support
    - Graceful shutdown implementation
  - Testing structure and development workflow

- **CONNECTRPC_SETUP_GUIDE.md**: Comprehensive ConnectRPC implementation guide
  - Installation instructions for Buf CLI and code generation tools
  - Complete Buf configuration (buf.yaml, buf.gen.yaml)
  - Protocol Buffer definition examples for Item Management Service
  - Server-side implementation patterns in Go:
    - ConnectRPC handler implementation with error mapping
    - Domain error to Connect error code conversion
    - Proto-to-domain and domain-to-proto converters
  - Client-side implementation examples:
    - Go client for service-to-service communication
    - TypeScript/React client for web frontend
    - React Query integration patterns
  - Testing strategies:
    - Unit testing ConnectRPC handlers with mocks
    - Integration testing with test clients
    - Testing with grpcurl command examples
  - Interceptors and middleware:
    - Authentication interceptor with JWT validation
    - Logging interceptor with structured logging
    - Metrics interceptor with Prometheus
  - Production considerations:
    - Timeout configuration (client and server)
    - Connection pooling setup
    - TLS configuration
    - Error handling best practices
    - Health checks and observability
  - Streaming examples (server streaming for real-time updates)
  - Troubleshooting common issues (CORS, protocol mismatch, timeouts)

- **OFFLINE_TRANSACTION_HANDLING.md**: Complete offline mode strategy and implementation
  - Architecture overview with offline/online mode comparison
  - Network connectivity monitoring:
    - Browser online/offline event handling
    - Backend health check implementation
    - Combined connectivity status hook
  - IndexedDB local storage schema:
    - LocalTransaction entity with sync status tracking
    - CachedItem and CachedCategory for offline access
    - SyncQueue for retry management
    - Complete Dexie database setup
  - Offline transaction flow:
    - Create transaction with automatic sale number generation
    - Tax calculation and change computation
    - Local storage with pending_sync status
    - Offline receipt component with clear offline mode indicators
  - Synchronization strategy:
    - Background sync service with automatic retry
    - Exponential backoff for failed syncs
    - Idempotency using sale numbers
    - Conflict-free sync design
    - Manual retry for failed transactions
  - Item caching for offline access:
    - Cache all active items and categories when online
    - Serve from cache when offline
    - Background refresh strategy
  - UI/UX components:
    - Offline mode indicator banner
    - Payment method restriction (cash-only when offline)
    - Sync status component with real-time updates
    - Failed sync alerts with retry button
  - Service Worker implementation for asset caching
  - Backend considerations:
    - Accept backdated transactions from offline terminals
    - Idempotency key handling to prevent duplicates
    - Timestamp validation
  - Security considerations:
    - No card data stored offline
    - Encrypted local storage recommendations
    - Audit trail for reconciliation
  - Monitoring and alerting:
    - Prometheus metrics for offline transaction tracking
    - Alert rules for sync failures and old transactions

- **PROTO_COMMON_TYPES.md**: Common protocol buffer type definitions
  - Shared value objects: Money, LocalizedString, Percentage, DateRange, Address
  - Common enums: PaymentMethod, SaleType, SaleStatus, UserRole, DeviceType, StockReason, OrderType
  - Proto3 syntax with decimal-as-string for precision
  - Complete proto file definition with documentation
  - Usage examples in Go and TypeScript
  - Validation rules and helper functions
  - Code generation setup with Buf CLI

- **ORDER_FULFILLMENT_SERVICE.md**: Complete Order Fulfillment Service design (~2300 lines)
  - Domain entities: Sale, SaleItem, PaymentMetadata, Void, ParkedOrder
  - Business rules and validation logic
  - Domain services with 6 use cases:
    - CreateSale with item validation and tax calculation
    - ProcessPayment with Payment Service integration
    - VoidSale with payment refunds
    - RefundSale for partial/full refunds
    - ParkOrder for saving incomplete orders
    - ResumeParkedOrder to continue saved orders
  - Repository ports: SaleRepository, ParkedOrderRepository, VoidRepository
  - External service ports:
    - PaymentServiceClient (transaction groups, split payments)
    - ItemManagementServiceClient (item validation, pricing)
    - CommunicationServiceClient (receipts, kitchen orders)
    - SupportingServiceClient (tax rates, validation)
  - Complete database schema with Goose migrations:
    - sales, sale_items, sale_payments, voids, parked_orders tables
    - Optimized indexes for performance
    - JSON columns for flexible data (modifiers, items)
  - SQLC queries with named arguments (sqlc.arg)
  - Complete ConnectRPC proto definitions:
    - OrderService with 7 RPC methods
    - Sale, SaleItem, PaymentMetadata, Void messages
    - Request/response types for all operations
  - Event publishing: sale.created, sale.completed, sale.voided, sale.refunded
  - Event consumption: payment.completed from Payment Service
  - Offline sync handling with sale number idempotency
  - Cross-service integration patterns (Payment, Item Management, Communication)
  - Comprehensive testing strategy (unit, integration, E2E)

- **SUPPORTING_SERVICE.md**: Complete Supporting Service design (~2400 lines)
  - Domain entities: User, Session, Customer, Location, Device
  - Authentication system with JWT (RS256):
    - Access tokens (1 hour lifetime)
    - Refresh tokens (7 days lifetime)
    - Token revocation via session tracking
    - HttpOnly cookies for refresh tokens (SECURITY_REVIEW.md compliance)
  - User management with RBAC:
    - Roles: Admin, Manager, Cashier, Kitchen
    - Permissions: CanVoidSales, CanRefund, CanEditPrices, etc.
    - Per-user permission overrides
  - Domain services with 10+ use cases:
    - Authenticate user with password verification
    - RefreshToken with session validation
    - Logout with session revocation
    - CreateUser with bcrypt password hashing
    - UpdateUserPermissions
    - ChangePassword with session cleanup
    - Customer management (create, update, portal access)
    - Location management with tax calculation
    - Device registration and heartbeat tracking
  - Repository ports: UserRepository, SessionRepository, CustomerRepository, LocationRepository, DeviceRepository
  - JWT signer interface with RS256 implementation:
    - Private key ONLY in Supporting Service
    - Public key distributed to all services
    - Claims: UserID, Role, Permissions, LocationID, TokenID
  - Complete database schema:
    - users, user_sessions, customers, locations, devices, settings, audit_logs
    - Session table for token revocation
    - Audit logging for compliance
  - SQLC queries with named arguments
  - Complete ConnectRPC proto definitions:
    - SupportingService with 20+ RPC methods
    - Authentication, user, customer, location, device operations
    - GetTaxRate and CalculateTax for location-level tax
  - Event publishing: user.created, user.permissions_updated, customer.created, device.registered
  - Security best practices from SECURITY_REVIEW.md:
    - bcrypt with cost factor 12
    - Token revocation on logout and password change
    - Session cleanup for expired tokens
    - Minimum password length (8 characters)
  - Permission middleware for authorization
  - Comprehensive testing strategy

- **COMMUNICATION_SERVICE.md**: Complete Communication Service design (~1600 lines)
  - Domain entities: ConnectedDevice, Event, Notification, KitchenOrder, Receipt
  - WebSocket/SSE architecture:
    - JWT authentication in first message (not URL)
    - Event subscription with pattern matching (sale.*, kitchen.*)
    - Location and device filtering
    - Heartbeat/ping every 30s
  - Domain services with real-time capabilities:
    - WebSocketService for connection management
    - NotificationService for multi-channel delivery
    - Event broadcasting with pub/sub pattern
  - Redis-based architecture:
    - connected_devices hash for active connections
    - device_subscriptions sets for event filtering
    - Pub/sub channels for event routing
    - Recent events list for replay
  - External adapter ports:
    - EmailPort (SendGrid, AWS SES, SMTP)
    - SMSPort (Twilio, AWS SNS)
    - PDFGeneratorPort (wkhtmltopdf, gotenberg)
  - Kitchen display system:
    - Real-time order updates
    - Status transitions (new → preparing → ready → completed)
    - Kitchen order history
  - Receipt delivery:
    - Email with PDF attachment
    - SMS with receipt link
    - Multi-format support (HTML, PDF, SMS)
  - Database schema (optional persistence):
    - notifications, kitchen_orders, receipts tables
    - Status tracking and delivery logs
  - Redis data structures documented:
    - Hash for devices
    - Sets for subscriptions
    - Pub/sub channels
    - Lists for event queues
  - Complete ConnectRPC proto definitions:
    - CommunicationService with 10+ RPC methods
    - Kitchen order streaming
    - Notification management
    - Event publishing
  - Event routing with pattern matching:
    - Wildcard support (sale.* matches sale.created, sale.completed)
    - Location filtering
    - Device filtering
  - Stateless design for horizontal scaling
  - Load testing strategy (100+ concurrent connections)

### Changed - 2025-11-03

#### From Previous Session
- **ITEM_MANAGEMENT_SERVICE.md**: Simplified tax handling
  - Removed TaxRule entity and tax_rule_id references from Item entity
  - Updated domain entities to reflect location-level tax (handled by Supporting Service)
  - Converted all SQLC queries from positional parameters ($1, $2) to named arguments (sqlc.arg(name))
  - Removed tax_rules table from database schema
  - Updated CreateItem, UpdateItem, and other queries to use named parameters
  - Added clear documentation that tax is handled at location level

- **HIGH_LEVEL_DESIGN.md**: Payment Service integration pattern
  - Replaced internal Payment Service design with external port/adapter pattern
  - Added PaymentServiceClient port interface with ConnectRPC adapter
  - Added Mock adapter for testing without external payment service
  - Updated microservices overview to show Payment Service as external dependency
  - Added transaction group design for split payment handling

### Technical Decisions - 2025-11-03

#### Architecture Patterns
- **Ports & Adapters (Hexagonal Architecture)**: Domain layer with zero dependencies on frameworks
- **ConnectRPC over gRPC**: Supports gRPC, gRPC-Web, Connect, and REST from single definition
- **Monorepo Structure**: All services in single repository with Go workspace
- **Event-Driven Denormalization**: Payment metadata cached locally, synced via events

#### Technology Stack
- **Backend**: Go 1.24+, PostgreSQL 15+, Redis
- **RPC Framework**: ConnectRPC (buf.build/connectrpc)
- **Database Tools**: SQLC (type-safe queries), Goose (migrations)
- **Code Generation**: Buf CLI for proto compilation
- **Frontend**: TypeScript, React, TanStack Query
- **Local Storage**: IndexedDB via Dexie

#### Business Logic Decisions
- **Tax Handling**: Location-level tax rates (not per-item) for single-location restaurant
- **Split Payments**: Transaction groups pattern (one sale → one group → N payments)
- **Offline Strategy**: Cash-only when offline, automatic sync when online
- **Idempotency**: Sale numbers used as idempotency keys to prevent duplicate syncs
- **Dependency Injection**: Manual DI initially (Google Wire optional for future)

### Notes

#### Services Architecture
The Modern POS system consists of 5 microservices:
1. **Item Management Service**: Menu items, categories, modifiers, stock
2. **Order Fulfillment Service**: Orders, sales, transaction management
3. **Communication Service**: Notifications, receipts, kitchen display
4. **Payment Service**: External integration (existing payment-service repository)
5. **Supporting Service**: Locations, terminals, tax settings, users, authentication

#### Offline-First Design Principles
- Business continuity during network outages
- Cash-only restriction prevents PCI compliance issues
- Local-first data storage with eventual consistency
- Clear UI feedback for offline mode
- Automatic background sync with retry logic
- Idempotent sync operations prevent duplicates

#### Design Phase Status
**All design documentation complete (100%)**:
- ✅ ENTITIES.md - Domain model with 15 entities
- ✅ MICROSERVICES.md - 5 microservices architecture
- ✅ API_ENDPOINTS.md - 100+ REST endpoints
- ✅ DATAFLOWS.md - 10 operational flows
- ✅ SECURITY_REVIEW.md - 14 security issues with fixes
- ✅ HIGH_LEVEL_DESIGN.md - Ports & Adapters with 50+ adapters
- ✅ PROJECT_STRUCTURE.md - Complete monorepo structure
- ✅ CONNECTRPC_SETUP_GUIDE.md - RPC implementation guide
- ✅ OFFLINE_TRANSACTION_HANDLING.md - Offline strategy
- ✅ PROTO_COMMON_TYPES.md - Shared proto definitions
- ✅ ITEM_MANAGEMENT_SERVICE.md - Complete service design
- ✅ ORDER_FULFILLMENT_SERVICE.md - Complete service design
- ✅ SUPPORTING_SERVICE.md - Complete service design
- ✅ COMMUNICATION_SERVICE.md - Complete service design
- ✅ SPRINT_PLAN.md - 4-week implementation plan

**Total Documentation**: ~12,000 lines across 15 files

#### Next Steps (Implementation Phase)
- Begin implementation starting with Supporting Service (foundation)
- Implement Item Management Service
- Implement Order Fulfillment Service
- Implement Communication Service
- Set up API Gateway (Kong or Envoy)
- Add distributed tracing (OpenTelemetry)
- Implement circuit breakers and rate limiting
- Set up monitoring (Prometheus + Grafana)
- Write end-to-end integration tests
- Deploy to staging environment

---

## Version History

### [0.1.0] - Design Phase

#### Context
This is the MVP design phase for a Modern POS system for a single-location restaurant. The system is being designed with offline-first capabilities, microservices architecture, and modern technology stack.

#### Goals
- Design robust, scalable POS architecture
- Support offline transaction processing
- Integrate with existing payment service
- Prepare for future multi-location expansion
- Maintain clean, maintainable codebase

---

## References

- [ConnectRPC Documentation](https://connectrpc.com/docs/introduction)
- [Buf Documentation](https://buf.build/docs)
- [SQLC Documentation](https://docs.sqlc.dev)
- [Goose Migrations](https://github.com/pressly/goose)
- [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)