# Token Refresh & Request Queue Flow

## Overview
This system implements a request queue mechanism that prevents multiple concurrent token refresh calls and reduces redundant API calls when a 401 occurs.

## How It Works

### Scenario: 8 Concurrent API Calls (1 gets 401)

```
Time T+0ms: 
  API-1 ──→ GET /products
  API-2 ──→ GET /orders
  API-3 ──→ GET /profile
  API-4 ──→ GET /memberships
  API-5 ──→ GET /bookings
  API-6 ──→ GET /auctions
  API-7 ──→ GET /cart
  API-8 ──→ GET /settings
  
  [All execute with current access token]

Time T+50ms:
  API-2 returns ❌ 401 Unauthorized
  ↓
  AuthInterceptor.onError() triggered
  ↓
  _queueManager.startRefresh() → Sets isRefreshing = true
  
  At same time, other APIs still in-flight:
  API-1, API-3, API-4, API-5, API-6, API-7, API-8 are waiting...

Time T+100ms:
  API-1 returns ❌ 401 (also fails, but sees isRefreshing = true)
  ↓
  Enters "wait for refresh" branch
  ↓
  _waitForRefresh() → Waits for refresh to complete
  
  API-3, API-4, API-5, API-6, API-7, API-8 also get 401
  ↓
  All see isRefreshing = true
  ↓
  All enter "wait for refresh" branch
  
  NO CONCURRENT REFRESH CALLS! ✅

Time T+500ms:
  First API (API-2) completes refresh:
  ↓
  POST /api/v1/auth/refresh with refreshToken
  ↓
  Response: { accessToken: "new_token", refreshToken: "new_refresh" }
  ↓
  Save tokens to secure storage
  ↓
  _queueManager.completeRefresh() → Sets isRefreshing = false
  ↓
  All waiting APIs wake up and retry with new token

Time T+550ms:
  All waiting APIs retry:
  API-1 ──→ GET /products [with new token] ✅ 200
  API-3 ──→ GET /profile [with new token] ✅ 200
  API-4 ──→ GET /memberships [with new token] ✅ 200
  API-5 ──→ GET /bookings [with new token] ✅ 200
  API-6 ──→ GET /auctions [with new token] ✅ 200
  API-7 ──→ GET /cart [with new token] ✅ 200
  API-8 ──→ GET /settings [with new token] ✅ 200
  
  (API-2 already retried as part of first refresh flow)

Total API Calls:
  8 (initial) + 1 (refresh) + 7 (retries) = 16 calls
  
Without this system:
  Each of 8 APIs would independently:
  - Try request → Get 401 → Refresh → Retry
  = 8 + 8 + 8 = 24 calls (or more if overlapping)
  
Savings: 33% reduction in API calls ✅
```

---

## Key Components

### 1. RequestQueueManager
**File:** `lib/core/api/request_queue_manager.dart`

A singleton that tracks and manages the token refresh state:

```dart
class RequestQueueManager {
  bool isRefreshing;  // Indicates if token refresh is in progress
  
  void startRefresh()    // Called when first 401 is detected
  void completeRefresh() // Called when token refresh succeeds
  void failRefresh()     // Called when token refresh fails
  void clear()           // Called on logout
}
```

**Purpose**: Acts as a global flag to coordinate all concurrent requests during token refresh.

### 2. AuthInterceptor Updates
**File:** `lib/core/api/interceptors/auth_interceptor.dart`

#### Flow for First 401:
```
Request gets 401
  ↓
onError() checks: isRefreshing == false ← First one!
  ↓
startRefresh() ← Block other 401s from refreshing
  ↓
POST /api/v1/auth/refresh
  ↓
Save new tokens
  ↓
completeRefresh() ← Signal waiting requests
  ↓
Retry original request
```

#### Flow for Subsequent 401s (while refreshing):
```
Request gets 401
  ↓
onError() checks: isRefreshing == true ← Wait!
  ↓
_waitForRefresh() ← Poll for refresh to complete (100ms intervals)
  ↓
Get new token from storage
  ↓
Retry request
```

### 3. _waitForRefresh() Method

Polls every 100ms to check if refresh is complete:
- Timeout: 30 seconds (prevents infinite loops)
- Lightweight busy-wait approach

```dart
Future<void> _waitForRefresh() async {
  final startTime = DateTime.now();
  const maxWait = Duration(seconds: 30);

  while (_queueManager.isRefreshing) {
    if (DateTime.now().difference(startTime) > maxWait) {
      throw Exception('Token refresh timeout');
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
```

---

## Benefits

✅ **Reduced API Calls**: From ~24 to ~16 (33% reduction)
✅ **No Race Conditions**: Only one refresh happens at a time
✅ **Better UX**: Batch retry after single token refresh
✅ **Fail-Safe**: 30-second timeout prevents stuck states
✅ **Clean Logout**: Clears queue on logout

---

## Testing This Flow

### Manual Test Procedure:

1. **Set up the app**
   - Open the app and log in successfully

2. **Trigger concurrent API calls**
   - Load a dashboard that makes multiple simultaneous requests
   - Examples: load products + orders + profile at the same time
   - Or: refresh multiple sections of the home screen

3. **Invalidate the access token**
   
   **Option A: Via Android Debug Bridge (ADB)**
   ```bash
   adb shell
   # Navigate to app data
   cd /data/data/com.thevaults.customer.dev/
   rm -f access_token  # Remove the token file
   ```
   
   **Option B: Via Backend**
   - Use your backend admin panel to invalidate the user's token
   
   **Option C: Manually in code (temporary)**
   - Add debug code to clear the token before making requests

4. **Trigger more API calls**
   - Load more API endpoints while token is invalid
   - Observe the refresh flow

5. **Expected behavior**
   - First API gets 401 → Starts refresh
   - Other APIs get 401 → See refresh in progress → Wait
   - After refresh completes → All retry together
   - Only ONE token refresh call is made ✅

---

## Logcat Patterns to Monitor

When testing, look for these patterns in Android Logcat or DevTools:

```
# First 401 detected
[AuthInterceptor] 401 detected on first request
[RequestQueueManager] Refresh started (isRefreshing=true)

# Other requests waiting
[AuthInterceptor] 401 detected but refresh already in progress - waiting...
[AuthInterceptor] Waiting for refresh to complete...

# Refresh completes
[AuthInterceptor] Refresh completed successfully
[RequestQueueManager] Refresh complete (isRefreshing=false)

# All requests retry
[AuthInterceptor] Retrying request with new token
[AuthInterceptor] Request retried successfully
```

---

## Edge Cases Handled

### ✅ Logout During Refresh
- Queue is cleared immediately
- Any waiting requests fail gracefully
- User redirected to login

### ✅ Multiple 401s
- All wait for first refresh
- Only one token refresh API call
- All retry together after refresh

### ✅ Refresh Timeout
- If refresh doesn't complete in 30 seconds
- Waiting requests fail
- Forces logout

### ✅ Refresh API Fails
- If `/api/v1/auth/refresh` returns error
- All waiting requests fail
- Forces logout
- User redirected to login

### ✅ No Refresh Token
- If stored refresh token is missing/empty
- Forces logout immediately
- No attempt to refresh
- User redirected to login

### ✅ Network Failure During Refresh
- Caught and treated as refresh failure
- Forces logout
- User can retry login

---

## API Contract

### Refresh Endpoint
```
POST /api/v1/auth/refresh
Content-Type: application/json

Request:
{
  "refreshToken": "previous_refresh_token"
}

Response (200 OK):
{
  "accessToken": "new_access_token",
  "refreshToken": "new_refresh_token"
}

Response (401 / 403):
- Refresh token invalid or expired
- Treated as refresh failure
- Forces logout
```

---

## Performance Impact

### Network Calls Reduction
| Scenario | Old System | New System | Reduction |
|----------|-----------|-----------|-----------|
| 1 API gets 401 | 3 calls (1 request + 1 refresh + 1 retry) | 3 calls | 0% |
| 8 APIs concurrent, 1 gets 401 | 24+ calls | ~16 calls | 33% |
| 8 APIs concurrent, 3 get 401 | 24+ calls | ~18 calls | 25% |

### Latency Impact
- **Minimal**: Waiting requests poll every 100ms (negligible overhead)
- **Timeout safety**: 30-second max wait prevents hanging UI

---

## Implementation Files

| File | Purpose |
|------|---------|
| `lib/core/api/request_queue_manager.dart` | Request queue state management |
| `lib/core/api/interceptors/auth_interceptor.dart` | Token refresh + retry logic |
| `lib/core/storage/secure_storage_service.dart` | Token persistence |
| `lib/core/api/api_endpoints.dart` | Refresh endpoint definition |

---

## Future Optimizations

- [ ] Replace polling with `Completer` for instant notification
- [ ] Add request deduplication (don't retry same request twice)
- [ ] Add exponential backoff for refresh retries
- [ ] Add metrics/logging for token refresh events
