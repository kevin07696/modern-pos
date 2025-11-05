# Modern POS - Security Implementation Guide

**Version**: 1.0
**Last Updated**: November 4, 2025
**Status**: Production Security Requirements

---

## Overview

This document defines critical security requirements and implementation patterns for the Modern POS system. All security issues must be addressed before production deployment (Sprint 4).

**Security Priority**: 🔴 Critical for production readiness

---

## Table of Contents

1. [Authentication & JWT Security](#1-authentication--jwt-security)
2. [Session Management](#2-session-management)
3. [API Security](#3-api-security)
4. [Input Validation](#4-input-validation)
5. [Payment Security](#5-payment-security)
6. [Real-Time Communication](#6-real-time-communication)
7. [Offline Mode Security](#7-offline-mode-security)
8. [Implementation Checklist](#8-implementation-checklist)

---

## 1. Authentication & JWT Security

### 1.1 Token Storage (CRITICAL)

✅ **CORRECT Implementation:**
```javascript
// Store access token in memory ONLY
let accessToken = null;

function setAccessToken(token) {
  accessToken = token;
}

// ❌ NEVER store in localStorage - vulnerable to XSS
// localStorage.setItem('accessToken', token); // DON'T DO THIS
```

⚠️ **Refresh Token Storage:**
```javascript
// Backend: Set refresh token as HttpOnly cookie
response.cookie('refreshToken', refreshToken, {
  httpOnly: true,      // Cannot be accessed by JavaScript (XSS-proof)
  secure: true,        // HTTPS only
  sameSite: 'strict',  // CSRF protection
  maxAge: 7 * 24 * 60 * 60 * 1000  // 7 days
});

// Frontend: Access token in memory, refresh via cookie
```

### 1.2 Token Revocation (CRITICAL)

⚠️ **SECURITY ISSUE**: Access tokens valid for 1 hour even after logout

**Solution: Token Versioning**
```go
// Include version in JWT claims
type TokenClaims struct {
    UserID       string
    TokenVersion int  // Incremented on logout
    Permissions  []string
    LocationID   string
    Exp          int64
}

// On logout: Increment user's token version
func (s *AuthService) Logout(userID string) error {
    query := `UPDATE users
              SET token_version = token_version + 1
              WHERE id = $1`
    _, err := s.db.Exec(query, userID)
    return err
}

// On every request: Validate token version
func (s *AuthService) ValidateToken(token string) (*TokenClaims, error) {
    claims, err := parseJWT(token)
    if err != nil {
        return nil, err
    }

    // Check token version against database
    var currentVersion int
    err = s.db.QueryRow(`SELECT token_version FROM users WHERE id = $1`,
        claims.UserID).Scan(&currentVersion)

    if err != nil {
        return nil, err
    }

    if claims.TokenVersion < currentVersion {
        return nil, errors.New("token revoked")
    }

    return claims, nil
}
```

**Why This Works:**
- Instant revocation on logout
- No blacklist needed
- Works for "logout all devices"
- Zero performance overhead

### 1.3 Password Security

✅ **CORRECT Implementation:**
```go
import "golang.org/x/crypto/bcrypt"

// Hash password on registration
func hashPassword(password string) (string, error) {
    bytes, err := bcrypt.GenerateFromPassword(
        []byte(password),
        bcrypt.DefaultCost,  // Cost factor 10
    )
    return string(bytes), err
}

// Verify password on login
func verifyPassword(hashedPassword, providedPassword string) error {
    return bcrypt.CompareHashAndPassword(
        []byte(hashedPassword),
        []byte(providedPassword),
    )
}
```

### 1.4 Rate Limiting (CRITICAL)

⚠️ **Brute Force Protection:**
```go
const MAX_LOGIN_ATTEMPTS = 5
const LOCKOUT_DURATION = 15 * time.Minute

func (s *AuthService) Login(username, password string) error {
    // 1. Check if account is locked
    attempts, err := s.redis.Get("login_attempts:" + username).Int()
    if err != nil && err != redis.Nil {
        return err
    }

    if attempts >= MAX_LOGIN_ATTEMPTS {
        ttl, _ := s.redis.TTL("login_attempts:" + username).Result()
        return fmt.Errorf("Account locked. Try again in %d minutes",
            int(ttl.Minutes()))
    }

    // 2. Validate credentials
    user, err := s.getUserByUsername(username)
    if err != nil {
        // Increment failed attempts
        s.incrementLoginAttempts(username)
        return errors.New("Invalid credentials")
    }

    if err := verifyPassword(user.PasswordHash, password); err != nil {
        s.incrementLoginAttempts(username)
        return errors.New("Invalid credentials")
    }

    // 3. Clear failed attempts on successful login
    s.redis.Del("login_attempts:" + username)

    return nil
}

func (s *AuthService) incrementLoginAttempts(username string) {
    key := "login_attempts:" + username
    s.redis.Incr(key)
    s.redis.Expire(key, LOCKOUT_DURATION)
}
```

---

## 2. Session Management

### 2.1 Cryptographically Random Session IDs

⚠️ **SECURITY ISSUE**: Predictable session IDs enable session hijacking

**Solution:**
```go
import "crypto/rand"
import "encoding/base64"

func generateSessionID() (string, error) {
    b := make([]byte, 32)  // 256 bits of entropy
    if _, err := rand.Read(b); err != nil {
        return "", err
    }
    return base64.URLEncoding.EncodeToString(b), nil
}
```

---

## 3. API Security

### 3.1 CSRF Protection (CRITICAL)

⚠️ **SECURITY ISSUE**: Cookie-based auth requires CSRF protection

**Solution: Double Submit Cookie Pattern**
```go
// 1. Generate CSRF token on login
func (s *AuthService) Login(...) (*LoginResponse, error) {
    // ... authenticate user ...

    // Generate CSRF token
    csrfToken, err := generateCSRFToken()
    if err != nil {
        return nil, err
    }

    // Set as cookie
    http.SetCookie(w, &http.Cookie{
        Name:     "csrf-token",
        Value:    csrfToken,
        HttpOnly: false,  // Readable by JavaScript
        Secure:   true,
        SameSite: http.SameSiteStrictMode,
        MaxAge:   7 * 24 * 60 * 60,
    })

    return &LoginResponse{
        AccessToken: accessToken,
        CSRFToken:   csrfToken,  // Also return in response
    }, nil
}

// 2. Validate CSRF token middleware
func csrfMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Skip for GET requests
        if r.Method == "GET" {
            next.ServeHTTP(w, r)
            return
        }

        // Get token from header
        headerToken := r.Header.Get("X-CSRF-Token")

        // Get token from cookie
        cookie, err := r.Cookie("csrf-token")
        if err != nil {
            http.Error(w, "CSRF token missing", http.StatusForbidden)
            return
        }

        // Tokens must match
        if headerToken != cookie.Value {
            http.Error(w, "CSRF token mismatch", http.StatusForbidden)
            return
        }

        next.ServeHTTP(w, r)
    })
}
```

**Frontend:**
```typescript
// Include CSRF token in requests
fetch('/api/v1/sales', {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${accessToken}`,
        'X-CSRF-Token': csrfToken,  // From login response
    },
    body: JSON.stringify(saleData),
});
```

### 3.2 Rate Limiting (Global)

```go
import "golang.org/x/time/rate"

var limiters = sync.Map{}

func rateLimitMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        userID := getUserIDFromToken(r)

        // Per-user limiter: 1000 requests/hour = ~17 req/min
        limiterInterface, _ := limiters.LoadOrStore(userID,
            rate.NewLimiter(rate.Every(time.Minute/17), 20)) // 20 burst

        limiter := limiterInterface.(*rate.Limiter)

        if !limiter.Allow() {
            http.Error(w, "Rate limit exceeded", http.StatusTooManyRequests)
            return
        }

        next.ServeHTTP(w, r)
    })
}
```

---

## 4. Input Validation

### 4.1 Comprehensive Validation (CRITICAL)

⚠️ **SECURITY ISSUE**: Insufficient input validation leads to injection attacks

**Solution:**
```go
func validateSaleRequest(req *CreateSaleRequest) error {
    // 1. Required fields
    if req.LocationID == "" {
        return errors.New("locationId required")
    }
    if len(req.Items) == 0 {
        return errors.New("at least one item required")
    }

    // 2. Data ranges (prevent DoS)
    if len(req.Items) > 1000 {
        return errors.New("too many items (max 1000)")
    }

    // 3. String lengths (prevent buffer overflow)
    if len(req.Notes) > 5000 {
        return errors.New("notes too long (max 5000 chars)")
    }

    // 4. Monetary values
    if req.Total < 0 {
        return errors.New("total cannot be negative")
    }
    if req.Total > 1000000 {  // $10,000 max (configurable)
        return errors.New("total exceeds maximum allowed")
    }

    // 5. UUID format validation
    if _, err := uuid.Parse(req.LocationID); err != nil {
        return errors.New("invalid locationId format")
    }

    // 6. Sanitize text fields (prevent XSS)
    req.Notes = sanitizeHTML(req.Notes)

    return nil
}

func sanitizeHTML(input string) string {
    // Remove HTML tags
    re := regexp.MustCompile(`<[^>]*>`)
    return re.ReplaceAllString(input, "")
}
```

### 4.2 SQL Injection Prevention

✅ **ALWAYS use parameterized queries:**
```go
// ✅ CORRECT - Parameterized query
query := `UPDATE stock
          SET quantity = quantity - $1
          WHERE item_id = $2 AND location_id = $3`
_, err := db.Exec(query, quantity, itemID, locationID)

// ❌ WRONG - String concatenation (NEVER DO THIS)
// query := fmt.Sprintf("UPDATE stock SET quantity = %d WHERE item_id = '%s'",
//     quantity, itemID)
```

---

## 5. Payment Security

### 5.1 Payment Amount Validation (CRITICAL)

⚠️ **SECURITY ISSUE**: Client could tamper with payment amount

**Solution:**
```go
// Payment Service must validate against Order Fulfillment
func (s *PaymentService) ProcessPayment(req *PaymentRequest) error {
    // 1. If sale reference provided, verify amount
    if req.SaleRef != "" {
        sale, err := s.orderClient.GetSale(req.SaleRef)
        if err != nil {
            return fmt.Errorf("failed to verify sale: %w", err)
        }

        if req.Amount != sale.Total {
            return errors.New("payment amount mismatch with sale total")
        }
    }

    // 2. Proceed with payment processing
    // ...
}
```

### 5.2 Webhook Security (CRITICAL)

⚠️ **SECURITY ISSUE**: Must verify webhooks are from legitimate payment gateway

**Solution: Signature Verification**
```go
import (
    "crypto/hmac"
    "crypto/sha256"
    "encoding/hex"
)

func verifyStripeWebhook(payload []byte, signature string) bool {
    secret := os.Getenv("STRIPE_WEBHOOK_SECRET")

    mac := hmac.New(sha256.New, []byte(secret))
    mac.Write(payload)
    expectedSignature := hex.EncodeToString(mac.Sum(nil))

    return hmac.Equal([]byte(signature), []byte(expectedSignature))
}

func handleStripeWebhook(w http.ResponseWriter, r *http.Request) {
    signature := r.Header.Get("Stripe-Signature")
    payload, _ := ioutil.ReadAll(r.Body)

    if !verifyStripeWebhook(payload, signature) {
        http.Error(w, "Invalid signature", http.StatusUnauthorized)
        return
    }

    // Process webhook safely
}
```

---

## 6. Real-Time Communication

### 6.1 WebSocket Authentication (CRITICAL)

⚠️ **SECURITY ISSUE**: Tokens in query string are logged everywhere

**Solution: Send token in first message**
```javascript
// ✅ CORRECT - Token in message
const ws = new WebSocket('wss://api.pos.com/ws');

ws.onopen = () => {
  ws.send(JSON.stringify({
    type: 'auth',
    token: accessToken  // From memory
  }));
};

// ❌ WRONG - Token in URL
// const ws = new WebSocket('wss://api.pos.com/ws?token=eyJ...');
```

**Server:**
```go
func handleWebSocket(conn *websocket.Conn) {
    // Wait for auth message (with timeout)
    conn.SetReadDeadline(time.Now().Add(5 * time.Second))

    var authMsg struct {
        Type  string `json:"type"`
        Token string `json:"token"`
    }

    if err := conn.ReadJSON(&authMsg); err != nil {
        conn.Close()
        return
    }

    if authMsg.Type != "auth" {
        conn.Close()
        return
    }

    // Validate JWT token
    claims, err := validateJWT(authMsg.Token)
    if err != nil {
        conn.Close()
        return
    }

    // Connection authenticated - remove deadline
    conn.SetReadDeadline(time.Time{})

    // Store connection with user context
    registerConnection(claims.UserID, conn)
}
```

### 6.2 Event Authorization

⚠️ **SECURITY ISSUE**: Unauthorized users could subscribe to sensitive events

**Solution:**
```go
func authorizeEventSubscription(claims *TokenClaims, eventPattern string) bool {
    // Admin can subscribe to everything
    if claims.Admin {
        return true
    }

    // Regular users - restrict by event type
    switch {
    case strings.HasPrefix(eventPattern, "sale."):
        // Staff can see sales at their location
        return true
    case strings.HasPrefix(eventPattern, "admin."):
        return false  // Admin-only events
    case strings.HasPrefix(eventPattern, "system."):
        return false  // System events for admins
    default:
        return false  // Deny by default
    }
}
```

---

## 7. Offline Mode Security

### 7.1 Offline Sales Validation (CRITICAL)

⚠️ **SECURITY ISSUE**: Client could tamper with offline sales before sync

**Solution: Server-Side Re-validation**
```go
func (s *SaleService) SyncOfflineSales(req *SyncRequest) ([]SyncResult, error) {
    results := make([]SyncResult, 0)

    for _, offlineSale := range req.OfflineSales {
        // 1. Check idempotency (UUID exists?)
        if s.saleExists(offlineSale.ID) {
            results = append(results, SyncResult{
                SaleID: offlineSale.ID,
                Status: "skipped",
                Reason: "already synced",
            })
            continue
        }

        // 2. Verify timestamp is recent (not backdated)
        if time.Since(offlineSale.Timestamp) > 24*time.Hour {
            results = append(results, SyncResult{
                SaleID: offlineSale.ID,
                Status: "rejected",
                Reason: "offline sale too old",
            })
            continue
        }

        // 3. Re-calculate totals server-side (DON'T TRUST CLIENT)
        serverTotals, err := s.calculateTotals(
            offlineSale.Items,
            offlineSale.LocationID,
            offlineSale.Timestamp,
        )
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

        // 5. Verify all items existed at sale time
        for _, item := range offlineSale.Items {
            if !s.itemExistedAt(item.ItemID, offlineSale.Timestamp) {
                results = append(results, SyncResult{
                    SaleID: offlineSale.ID,
                    Status: "rejected",
                    Reason: fmt.Sprintf("item %s didn't exist", item.ItemID),
                })
                continue
            }
        }

        // 6. Create sale
        if err := s.createSale(offlineSale); err != nil {
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

## 8. Implementation Checklist

### Sprint 1-2 (Basic Security)
- [ ] JWT RS256 signing
- [ ] Access tokens in memory
- [ ] Password hashing with bcrypt
- [ ] Parameterized SQL queries
- [ ] Basic input validation

### Sprint 3 (Advanced Security)
- [ ] HttpOnly cookies for refresh tokens
- [ ] Token versioning for revocation
- [ ] CSRF protection (double submit cookie)
- [ ] Rate limiting middleware
- [ ] WebSocket auth via message (not query string)
- [ ] Offline sale server-side validation

### Sprint 4 (Production Security)
- [ ] Comprehensive input validation
- [ ] Payment amount cross-verification
- [ ] Webhook signature verification
- [ ] Event authorization
- [ ] Brute force protection (login attempts)
- [ ] Security audit & penetration testing
- [ ] HTTPS/TLS 1.3 enforced
- [ ] Security headers (CSP, HSTS, X-Frame-Options)

---

## Critical Security Rules

1. ✅ **NEVER trust client input** - Always validate server-side
2. ✅ **NEVER store sensitive tokens in localStorage** - Use memory + HttpOnly cookies
3. ✅ **NEVER log tokens** - Keep tokens out of query strings and logs
4. ✅ **ALWAYS use parameterized queries** - Prevent SQL injection
5. ✅ **ALWAYS verify webhook signatures** - Prevent fake payment notifications
6. ✅ **ALWAYS re-calculate totals server-side** - Client amounts can be tampered
7. ✅ **ALWAYS use HTTPS in production** - No exceptions
8. ✅ **ALWAYS implement rate limiting** - Prevent brute force and DoS

---

**Next**: Implement security measures progressively across Sprint 1-4, with full audit before production deployment.
