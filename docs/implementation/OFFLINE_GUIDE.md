# Modern POS - Offline Mode Implementation Guide

**Version**: 1.0
**Last Updated**: November 4, 2025
**Target Sprint**: Sprint 3
**Status**: Reference for Implementation

---

## Overview

This guide provides implementation details for offline transaction handling in the Modern POS system. Offline mode allows cash-only sales when internet connectivity is lost, with automatic synchronization when connectivity is restored.

### Design Principles

1. **Cash-Only Offline**: Only cash payments accepted when offline (no card processing)
2. **Local-First**: All transaction data stored locally first (IndexedDB), then synced
3. **Conflict-Free**: UUID-based idempotency eliminates sync conflicts
4. **Graceful Degradation**: Clear UI indicating offline mode
5. **Eventual Consistency**: Temporary inconsistency acceptable, guaranteed sync

---

## Architecture

```
┌──────────────────────────────────────────┐
│        POS Terminal (Web App)            │
│  ┌──────────┐      ┌──────────────┐     │
│  │  Online  │ ◄──► │   Offline    │     │
│  │   Mode   │      │    Mode      │     │
│  │ All pmts │      │  Cash only   │     │
│  └──────────┘      └──────────────┘     │
└──────────┬─────────────────┬─────────────┘
           │                 │
           ▼                 ▼
┌──────────────────────────────────────────┐
│         IndexedDB (Local Storage)        │
│  • Transactions (pending sync)           │
│  • Items (cached)                        │
│  • Sync Queue                            │
└──────────┬───────────────────────────────┘
           │ When online
           ▼
┌──────────────────────────────────────────┐
│      Backend Services (Cloud)            │
│  • Order Fulfillment Service             │
│  • Item Management Service               │
└──────────────────────────────────────────┘
```

---

## 1. Connectivity Detection

### React Hook: useOnlineStatus

```typescript
// web/src/hooks/useOnlineStatus.ts
import { useState, useEffect } from 'react';

export function useOnlineStatus() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const [lastOnline, setLastOnline] = useState<Date | null>(null);

  useEffect(() => {
    function handleOnline() {
      setIsOnline(true);
      setLastOnline(new Date());
    }

    function handleOffline() {
      setIsOnline(false);
    }

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return { isOnline, lastOnline };
}
```

### React Hook: useBackendHealth

```typescript
// web/src/hooks/useBackendHealth.ts
import { useQuery } from '@tanstack/react-query';

interface HealthStatus {
  isHealthy: boolean;
  lastCheck: Date;
  latency: number;
  services: {
    orderFulfillment: boolean;
    itemManagement: boolean;
  };
}

export function useBackendHealth() {
  const { data, error } = useQuery({
    queryKey: ['health'],
    queryFn: async (): Promise<HealthStatus> => {
      const start = Date.now();

      // Ping health endpoints
      const [orderHealth, itemHealth] = await Promise.allSettled([
        fetch('http://localhost:8080/health').then(r => r.ok),
        fetch('http://localhost:8081/health').then(r => r.ok),
      ]);

      return {
        isHealthy: orderHealth.status === 'fulfilled' && orderHealth.value,
        lastCheck: new Date(),
        latency: Date.now() - start,
        services: {
          orderFulfillment: orderHealth.status === 'fulfilled' && orderHealth.value,
          itemManagement: itemHealth.status === 'fulfilled' && itemHealth.value,
        },
      };
    },
    refetchInterval: 30000, // Check every 30 seconds
    retry: 1,
    retryDelay: 1000,
  });

  return {
    isBackendHealthy: data?.isHealthy ?? false,
    healthStatus: data,
    error,
  };
}
```

### Combined Connectivity Hook

```typescript
// web/src/hooks/useConnectivity.ts
import { useOnlineStatus } from './useOnlineStatus';
import { useBackendHealth } from './useBackendHealth';

export function useConnectivity() {
  const { isOnline } = useOnlineStatus();
  const { isBackendHealthy } = useBackendHealth();

  // Consider "online" only if both network and backend are available
  const isFullyOnline = isOnline && isBackendHealthy;

  return {
    isOnline: isFullyOnline,
    networkOnline: isOnline,
    backendHealthy: isBackendHealthy,
    mode: isFullyOnline ? 'online' : 'offline',
  };
}
```

---

## 2. IndexedDB Schema

### Database Schema with Dexie

```typescript
// web/src/lib/db.ts
import Dexie, { Table } from 'dexie';

export interface LocalTransaction {
  id: string; // Client-generated UUID (for idempotency)
  locationId: string;
  terminalId: string;
  items: LocalTransactionItem[];
  subtotal: string; // Decimal as string
  tax: string;
  total: string;
  paymentMethod: 'CASH';
  paymentAmount: string;
  changeGiven: string;
  customerId?: string;
  orderType: 'DINE_IN' | 'TAKEOUT' | 'DELIVERY';
  status: 'pending_sync' | 'synced' | 'sync_failed';
  createdAt: Date;
  syncedAt?: Date;
  syncAttempts: number;
  syncError?: string;
}

export interface LocalTransactionItem {
  itemId: string;
  sku: string;
  name: string;
  quantity: number;
  unitPrice: string;
  subtotal: string;
  modifiers?: LocalModifier[];
}

export interface LocalModifier {
  modifierId: string;
  name: string;
  price: string;
}

export interface CachedItem {
  id: string;
  sku: string;
  name: { en: string };
  price: string;
  categoryId: string;
  active: boolean;
  lastUpdated: Date;
}

export interface SyncQueueItem {
  id: string;
  operation: 'create_transaction';
  entityType: 'transaction';
  entityId: string;
  payload: any;
  createdAt: Date;
  attempts: number;
  lastAttempt?: Date;
  error?: string;
}

export class POSDatabase extends Dexie {
  transactions!: Table<LocalTransaction, string>;
  items!: Table<CachedItem, string>;
  syncQueue!: Table<SyncQueueItem, string>;

  constructor() {
    super('modern-pos-db');

    this.version(1).stores({
      transactions: 'id, status, createdAt, syncedAt',
      items: 'id, sku, categoryId, active, lastUpdated',
      syncQueue: 'id, operation, entityId, createdAt, attempts',
    });
  }
}

export const db = new POSDatabase();
```

---

## 3. Create Offline Transaction

```typescript
// web/src/lib/offline-transactions.ts
import { v4 as uuidv4 } from 'uuid';
import { db, LocalTransaction } from './db';

interface CreateOfflineTransactionInput {
  locationId: string;
  terminalId: string;
  items: {
    itemId: string;
    sku: string;
    name: string;
    quantity: number;
    unitPrice: string;
  }[];
  orderType: 'DINE_IN' | 'TAKEOUT' | 'DELIVERY';
  paymentAmount: string; // Cash amount received
  taxRate: string; // e.g., "0.0875" for 8.75%
}

export async function createOfflineTransaction(
  input: CreateOfflineTransactionInput
): Promise<LocalTransaction> {
  // Calculate totals
  const subtotal = input.items.reduce((sum, item) => {
    return sum + (parseFloat(item.unitPrice) * item.quantity);
  }, 0);

  const tax = subtotal * parseFloat(input.taxRate);
  const total = subtotal + tax;
  const changeGiven = parseFloat(input.paymentAmount) - total;

  if (changeGiven < 0) {
    throw new Error('Payment amount is less than total');
  }

  // Create transaction with pre-generated UUID
  const transaction: LocalTransaction = {
    id: uuidv4(),  // Critical: Pre-generate UUID for idempotency
    locationId: input.locationId,
    terminalId: input.terminalId,
    items: input.items.map(item => ({
      itemId: item.itemId,
      sku: item.sku,
      name: item.name,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      subtotal: (parseFloat(item.unitPrice) * item.quantity).toFixed(2),
    })),
    subtotal: subtotal.toFixed(2),
    tax: tax.toFixed(2),
    total: total.toFixed(2),
    paymentMethod: 'CASH',
    paymentAmount: input.paymentAmount,
    changeGiven: changeGiven.toFixed(2),
    orderType: input.orderType,
    status: 'pending_sync',
    createdAt: new Date(),
    syncAttempts: 0,
  };

  // Save to IndexedDB
  await db.transactions.add(transaction);

  // Add to sync queue
  await db.syncQueue.add({
    id: uuidv4(),
    operation: 'create_transaction',
    entityType: 'transaction',
    entityId: transaction.id,
    payload: transaction,
    createdAt: new Date(),
    attempts: 0,
  });

  return transaction;
}
```

---

## 4. Sync Queue Processing

### Sync Manager

```typescript
// web/src/lib/sync-manager.ts
import { db } from './db';
import { createSaleAPI } from '../api/sales';

export class SyncManager {
  private isSyncing = false;
  private syncInterval?: NodeJS.Timeout;

  startAutoSync() {
    // Sync every 30 seconds when online
    this.syncInterval = setInterval(() => {
      this.sync();
    }, 30000);

    // Immediate sync on start
    this.sync();
  }

  stopAutoSync() {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
    }
  }

  async sync(): Promise<void> {
    if (this.isSyncing) {
      return; // Prevent concurrent syncs
    }

    this.isSyncing = true;

    try {
      const pendingItems = await db.syncQueue
        .where('attempts')
        .below(5)  // Max 5 retry attempts
        .toArray();

      for (const item of pendingItems) {
        try {
          await this.syncItem(item);

          // Mark transaction as synced
          await db.transactions.update(item.entityId, {
            status: 'synced',
            syncedAt: new Date(),
          });

          // Remove from sync queue
          await db.syncQueue.delete(item.id);
        } catch (error) {
          // Update retry count
          await db.syncQueue.update(item.id, {
            attempts: item.attempts + 1,
            lastAttempt: new Date(),
            error: error instanceof Error ? error.message : 'Unknown error',
          });

          // Update transaction status
          await db.transactions.update(item.entityId, {
            status: 'sync_failed',
            syncAttempts: item.attempts + 1,
            syncError: error instanceof Error ? error.message : 'Unknown error',
          });
        }
      }
    } finally {
      this.isSyncing = false;
    }
  }

  private async syncItem(item: SyncQueueItem): Promise<void> {
    if (item.operation === 'create_transaction') {
      const transaction = item.payload as LocalTransaction;

      // Call backend API with pre-generated UUID
      await createSaleAPI({
        id: transaction.id,  // Include UUID for idempotency
        locationId: transaction.locationId,
        items: transaction.items.map(item => ({
          itemId: item.itemId,
          quantity: item.quantity,
          unitPrice: parseInt((parseFloat(item.unitPrice) * 100).toFixed(0)), // Convert to cents
        })),
        orderType: transaction.orderType,
        paymentMethod: 'CASH',
        paymentAmount: parseInt((parseFloat(transaction.paymentAmount) * 100).toFixed(0)),
        createdAt: transaction.createdAt.toISOString(),  // Backdate timestamp
      });
    }
  }
}

export const syncManager = new SyncManager();
```

### React Hook for Sync Status

```typescript
// web/src/hooks/useSyncStatus.ts
import { useState, useEffect } from 'react';
import { db } from '../lib/db';
import { useLiveQuery } from 'dexie-react-hooks';

export function useSyncStatus() {
  const pendingCount = useLiveQuery(
    () => db.transactions.where('status').equals('pending_sync').count(),
    []
  );

  const failedCount = useLiveQuery(
    () => db.transactions.where('status').equals('sync_failed').count(),
    []
  );

  return {
    pendingCount: pendingCount ?? 0,
    failedCount: failedCount ?? 0,
    hasPending: (pendingCount ?? 0) > 0,
    hasFailed: (failedCount ?? 0) > 0,
  };
}
```

---

## 5. UI Components

### Offline Mode Banner

```typescript
// web/src/components/OfflineBanner.tsx
import React from 'react';
import { useConnectivity } from '../hooks/useConnectivity';
import { useSyncStatus } from '../hooks/useSyncStatus';

export function OfflineBanner() {
  const { mode, networkOnline, backendHealthy } = useConnectivity();
  const { pendingCount } = useSyncStatus();

  if (mode === 'online') {
    return null; // Don't show banner when online
  }

  return (
    <div className="bg-yellow-500 text-white px-4 py-2 text-center">
      <div className="flex items-center justify-center gap-2">
        <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
          <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
        </svg>
        <span className="font-semibold">
          OFFLINE MODE - Cash Only
        </span>
      </div>
      {pendingCount > 0 && (
        <div className="text-sm mt-1">
          {pendingCount} transaction{pendingCount > 1 ? 's' : ''} pending sync
        </div>
      )}
      {!networkOnline && <div className="text-sm">Network: Disconnected</div>}
      {!backendHealthy && <div className="text-sm">Backend: Unavailable</div>}
    </div>
  );
}
```

---

## 6. Backend: Server-Side Validation

**CRITICAL**: Server must re-validate ALL offline sales

```go
// services/order-fulfillment/internal/domain/sale_service.go
func (s *SaleService) SyncOfflineSales(ctx context.Context, sales []*SyncSaleRequest) ([]SyncResult, error) {
    results := make([]SyncResult, 0)

    for _, offlineSale := range sales {
        // 1. Check idempotency (UUID exists?)
        if s.saleRepo.Exists(ctx, offlineSale.ID) {
            results = append(results, SyncResult{
                SaleID: offlineSale.ID,
                Status: "skipped",
                Reason: "already synced",
            })
            continue
        }

        // 2. Verify timestamp not too old (24h max)
        if time.Since(offlineSale.CreatedAt) > 24*time.Hour {
            results = append(results, SyncResult{
                SaleID: offlineSale.ID,
                Status: "rejected",
                Reason: "offline sale too old",
            })
            continue
        }

        // 3. Re-calculate totals server-side (DON'T TRUST CLIENT)
        serverTotals, err := s.calculateTotals(ctx, offlineSale.Items, offlineSale.LocationID)
        if err != nil {
            results = append(results, SyncResult{
                SaleID: offlineSale.ID,
                Status: "rejected",
                Reason: fmt.Sprintf("calculation error: %v", err),
            })
            continue
        }

        // 4. Verify totals match
        if offlineSale.Total != serverTotals.Total {
            results = append(results, SyncResult{
                SaleID: offlineSale.ID,
                Status: "rejected",
                Reason: "total mismatch",
            })
            continue
        }

        // 5. Create sale with backdated timestamp
        sale := &Sale{
            ID:         offlineSale.ID,  // Use client UUID
            LocationID: offlineSale.LocationID,
            Items:      offlineSale.Items,
            Total:      serverTotals.Total,
            Status:     SaleStatusCompleted,
            CreatedAt:  offlineSale.CreatedAt,  // Backdate
        }

        if err := s.saleRepo.Create(ctx, sale); err != nil {
            results = append(results, SyncResult{
                SaleID: offlineSale.ID,
                Status: "error",
                Reason: err.Error(),
            })
            continue
        }

        results = append(results, SyncResult{
            SaleID: offlineSale.ID,
            Status: "synced",
        })
    }

    return results, nil
}
```

---

## Implementation Checklist

### Sprint 3 (Offline Mode)

- [ ] Create connectivity hooks (useOnlineStatus, useBackendHealth)
- [ ] Set up IndexedDB with Dexie
- [ ] Implement offline transaction creation
- [ ] Build sync queue manager
- [ ] Add offline mode UI banner
- [ ] Implement backend sync endpoint with validation
- [ ] Test offline → online transition
- [ ] Test sync retry logic
- [ ] Handle sync failures gracefully
- [ ] Add sync status indicators

---

**Next**: Use this guide to create Sprint 3 task files for offline mode implementation.
