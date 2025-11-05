# Intelligent Prep Time Estimation

**Status**: Backlog (Future Enhancement)
**Story Points**: 5
**Assignee**: TBD
**Priority**: P2 - Medium (Nice to Have)
**Dependencies**: S1.14 (Kitchen Display UI)

---

## User Story

As a **restaurant manager**, I want **intelligent prep time estimates based on historical data** so that **kitchen displays show accurate completion times and improve operational efficiency**.

---

## Description

Add prep_time field to items with initial seed estimates, track actual preparation times in production, and run nightly analysis during closing hours to refine estimates based on real performance data. This transforms the kitchen display from showing simple "time elapsed" to intelligent "estimated completion time" predictions.

The system learns from actual kitchen performance and continuously improves accuracy over time.

---

## Acceptance Criteria

### Data Model
- [ ] prep_time_minutes field added to items table
- [ ] prep_time_minutes field added to sale_items table (snapshot)
- [ ] Seed data includes initial estimates for all items
- [ ] Proto definitions updated for Item and SaleItem

### Kitchen Display Enhancement
- [ ] Shows estimated completion time (created_at + max(item prep_times))
- [ ] Shows time remaining until completion
- [ ] Color coding based on schedule (not age):
  - Green: On track (time_remaining > 5 min)
  - Yellow: Tight (time_remaining 0-5 min)
  - Red: Overdue (time_remaining < 0)
- [ ] Sorts by estimated completion time (soonest first)

### Actual Time Tracking
- [ ] Track when order moves to "preparing" status
- [ ] Track when order moves to "ready" status
- [ ] Calculate actual_prep_time = ready_time - preparing_time
- [ ] Store in order_prep_analytics table

### Automated Analysis
- [ ] Cron job runs nightly at closing time
- [ ] Analyzes last 30 days of prep time data per item
- [ ] Calculates median prep time (ignore outliers)
- [ ] Updates item.prep_time_minutes with refined estimate
- [ ] Logs changes for review

---

## Definition of Done

- [x] Database schema updated with prep_time fields
- [x] Proto definitions include prep_time
- [x] Seed data includes initial estimates
- [x] Kitchen display shows completion estimates
- [x] Actual prep time tracking implemented
- [x] Analytics table created
- [x] Cron job scheduled and tested
- [x] Analysis algorithm validated
- [x] UI updated and tested
- [x] Code reviewed and approved

---

## Technical Details

### Database Schema Changes

```sql
-- Add to items table
ALTER TABLE items
ADD COLUMN prep_time_minutes INT DEFAULT 15;  -- Default 15 min estimate

-- Add to sale_items table (snapshot pattern)
ALTER TABLE sale_items
ADD COLUMN prep_time_minutes INT DEFAULT 15;

-- Analytics table for actual prep times
CREATE TABLE order_prep_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID NOT NULL REFERENCES sales(id),
    item_id UUID NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    location_id UUID NOT NULL,

    -- Timestamps
    order_created_at TIMESTAMPTZ NOT NULL,
    preparing_started_at TIMESTAMPTZ NOT NULL,
    ready_at TIMESTAMPTZ NOT NULL,

    -- Calculated
    actual_prep_time_minutes INT NOT NULL,  -- ready - preparing
    estimated_prep_time_minutes INT NOT NULL,  -- from item at sale time
    variance_minutes INT NOT NULL,  -- actual - estimated

    -- Context (for analysis)
    day_of_week INT NOT NULL,  -- 0=Sunday, 6=Saturday
    hour_of_day INT NOT NULL,  -- 0-23
    order_size INT NOT NULL,   -- Total items in order

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_prep_analytics_item ON order_prep_analytics(item_id, created_at DESC);
CREATE INDEX idx_order_prep_analytics_location ON order_prep_analytics(location_id, created_at DESC);
```

### Proto Updates

```protobuf
// item/v1/item_service.proto
message Item {
  // ... existing fields ...
  int32 prep_time_minutes = 14;  // Estimated prep time
}

// order/v1/order_service.proto
message SaleItem {
  // ... existing fields ...
  int32 prep_time_minutes = 14;  // Snapshot from item
}
```

### Kitchen Display Logic

```typescript
interface EnhancedKitchenOrder {
  orderNumber: string;
  createdAt: Date;
  items: Array<{
    name: string;
    quantity: number;
    prepTimeMinutes: number;
  }>;

  // Calculated fields
  maxPrepTime: number;  // Max of all item prep times
  estimatedCompletionTime: Date;  // createdAt + maxPrepTime
  timeRemaining: number;  // minutes until completion
  isOverdue: boolean;
  urgencyLevel: 'on-track' | 'tight' | 'overdue';
}

function calculateOrderMetrics(order: KitchenOrder): EnhancedKitchenOrder {
  const maxPrepTime = Math.max(...order.items.map(i => i.prepTimeMinutes));
  const estimatedCompletion = new Date(order.createdAt.getTime() + maxPrepTime * 60000);
  const timeRemaining = (estimatedCompletion.getTime() - Date.now()) / 60000;

  let urgencyLevel: string;
  if (timeRemaining > 5) urgencyLevel = 'on-track';
  else if (timeRemaining >= 0) urgencyLevel = 'tight';
  else urgencyLevel = 'overdue';

  return {
    ...order,
    maxPrepTime,
    estimatedCompletionTime: estimatedCompletion,
    timeRemaining: Math.round(timeRemaining),
    isOverdue: timeRemaining < 0,
    urgencyLevel,
  };
}
```

### Tracking Actual Prep Time

```go
// When order status changes to "preparing"
func (s *KitchenService) MarkOrderPreparing(ctx context.Context, orderID uuid.UUID) error {
    now := time.Now()

    // Update kitchen_orders.preparing_started_at
    err := s.repo.UpdatePreparingStarted(ctx, orderID, now)
    if err != nil {
        return err
    }

    return nil
}

// When order status changes to "ready"
func (s *KitchenService) MarkOrderReady(ctx context.Context, orderID uuid.UUID) error {
    now := time.Now()

    // Get order with timestamps
    order, err := s.repo.GetOrder(ctx, orderID)
    if err != nil {
        return err
    }

    // Calculate actual prep time
    actualPrepTime := now.Sub(order.PreparingStartedAt).Minutes()

    // Store analytics for each item
    for _, item := range order.Items {
        analytics := &OrderPrepAnalytics{
            SaleID:                   order.SaleID,
            ItemID:                   item.ItemID,
            ItemName:                 item.Name,
            LocationID:               order.LocationID,
            OrderCreatedAt:           order.CreatedAt,
            PreparingStartedAt:       order.PreparingStartedAt,
            ReadyAt:                  now,
            ActualPrepTimeMinutes:    int(actualPrepTime),
            EstimatedPrepTimeMinutes: item.PrepTimeMinutes,
            VarianceMinutes:          int(actualPrepTime) - item.PrepTimeMinutes,
            DayOfWeek:                int(now.Weekday()),
            HourOfDay:                now.Hour(),
            OrderSize:                len(order.Items),
        }

        err = s.analyticsRepo.CreatePrepAnalytics(ctx, analytics)
        if err != nil {
            log.Error("failed to store prep analytics", "error", err)
            // Don't fail the order - just log
        }
    }

    // Update order status
    return s.repo.UpdateOrderStatus(ctx, orderID, "ready", now)
}
```

### Nightly Analysis Cron Job

```go
// Schedule: Every day at 2:00 AM (after closing)
// Cron: 0 2 * * *

func (s *AnalyticsService) RefineEstimates(ctx context.Context) error {
    log.Info("Starting nightly prep time analysis")

    // Get all items
    items, err := s.itemRepo.ListAllItems(ctx)
    if err != nil {
        return err
    }

    for _, item := range items {
        // Get last 30 days of actual prep times
        since := time.Now().AddDate(0, 0, -30)
        analytics, err := s.analyticsRepo.GetPrepTimesForItem(ctx, item.ID, since)
        if err != nil {
            log.Error("failed to get analytics", "item_id", item.ID, "error", err)
            continue
        }

        if len(analytics) < 5 {
            // Need at least 5 data points
            log.Debug("insufficient data", "item_id", item.ID, "count", len(analytics))
            continue
        }

        // Calculate median (more robust than mean for outliers)
        prepTimes := make([]int, len(analytics))
        for i, a := range analytics {
            prepTimes[i] = a.ActualPrepTimeMinutes
        }
        sort.Ints(prepTimes)
        median := prepTimes[len(prepTimes)/2]

        // Only update if significantly different (>10% change)
        currentEstimate := item.PrepTimeMinutes
        percentChange := math.Abs(float64(median-currentEstimate)) / float64(currentEstimate)

        if percentChange > 0.10 {
            log.Info("updating prep time estimate",
                "item", item.Name,
                "old", currentEstimate,
                "new", median,
                "samples", len(analytics),
            )

            err = s.itemRepo.UpdatePrepTime(ctx, item.ID, median)
            if err != nil {
                log.Error("failed to update prep time", "error", err)
            }
        }
    }

    log.Info("Nightly prep time analysis complete")
    return nil
}
```

### Seed Data with Initial Estimates

```go
// Initial estimates (in minutes)
items := []*itemv1.Item{
    // Fast items
    {Name: "Soft Drink", PrepTimeMinutes: 1},
    {Name: "Iced Tea", PrepTimeMinutes: 2},
    {Name: "Fortune Cookie", PrepTimeMinutes: 1},

    // Appetizers (5-10 min)
    {Name: "Spring Rolls", PrepTimeMinutes: 8},
    {Name: "Egg Rolls", PrepTimeMinutes: 8},
    {Name: "Dumplings", PrepTimeMinutes: 10},

    // Entrees (12-20 min)
    {Name: "Kung Pao Chicken", PrepTimeMinutes: 15},
    {Name: "Orange Chicken", PrepTimeMinutes: 15},
    {Name: "Beef & Broccoli", PrepTimeMinutes: 12},
    {Name: "General Tso's Chicken", PrepTimeMinutes: 18},
    {Name: "Fried Rice", PrepTimeMinutes: 10},

    // Complex items (20-30 min)
    {Name: "Peking Duck", PrepTimeMinutes: 30},
    {Name: "Whole Steamed Fish", PrepTimeMinutes: 25},
}
```

---

## Implementation Steps

1. Add prep_time_minutes column to items table
2. Add prep_time_minutes column to sale_items table
3. Update Item proto definition
4. Update SaleItem proto definition
5. Regenerate proto code
6. Create order_prep_analytics table
7. Update seed data with initial estimates
8. Modify kitchen display to calculate completion times
9. Update color coding logic (schedule-based)
10. Add tracking when order status changes
11. Create AnalyticsService with RefineEstimates method
12. Set up cron job (2:00 AM daily)
13. Test with mock data
14. Deploy to production
15. Monitor for 30 days, review accuracy improvements

---

## Testing

### Manual Test Cases

**Test 1: Kitchen display shows estimates**
```
Given: Order created at 2:00 PM with:
  - 2× Kung Pao Chicken (15 min each)
  - 1× Fried Rice (10 min)
When: Kitchen display loads
Then: Shows "Est. ready: 2:15 PM" (max prep time = 15 min)
And: Shows "5 min remaining" if current time is 2:10 PM
```

**Test 2: Analytics tracking**
```
Given: Order marked "preparing" at 2:00 PM
And: Order marked "ready" at 2:12 PM
When: Analytics saved
Then: order_prep_analytics shows actual_prep_time_minutes = 12
And: Shows variance vs estimate
```

**Test 3: Nightly refinement**
```
Given: 30 days of data for Kung Pao Chicken:
  - Median actual time: 18 minutes
  - Current estimate: 15 minutes
  - Variance: +20%
When: Cron job runs
Then: Updates item.prep_time_minutes to 18
And: Logs the change
```

---

## Time Estimate

**Estimated**: 3 hours (schema) + 2 hours (display) + 3 hours (analytics) + 2 hours (testing)
**Actual**: ___ hours

---

## Notes

### Why Median Instead of Mean?
- Median is robust to outliers (e.g., new trainee takes 45 min)
- More representative of typical performance
- Less sensitive to exceptional cases

### Why Only Update on >10% Change?
- Prevents thrashing from normal variance
- Estimates stabilize over time
- Reduces unnecessary updates

### Future Enhancements
- **Context-aware estimates**: Adjust for time of day, day of week, order size
- **Kitchen capacity**: Factor in number of orders being prepared simultaneously
- **Staff skill levels**: Different estimates based on who's cooking
- **Real-time learning**: Update estimates during service (not just nightly)
- **Predicted delays**: "Kitchen is running 10 minutes behind schedule"

### Machine Learning Opportunity
This data enables ML models to predict:
- Kitchen capacity planning
- Staff scheduling optimization
- Menu pricing based on prep complexity
- Customer wait time messaging

---

## Related Stories

- **S1.14**: Kitchen Display UI (base implementation)
- **S4.13**: Sales Reports (can include prep time analysis)
- **Future**: Predictive kitchen load balancing
- **Future**: Customer wait time notifications
