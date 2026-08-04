# Rate-Limit Interceptor & Telemetry — Design

Status: approved for planning
Date: 2026-08-04
Scope: sub-project 1 of 4 in the "no user ever sees a throttling issue" initiative. Applies identically to `the_vaults_customer` and `the_vaults_vendor` (independent Flutter apps, no shared package — this design is implemented once per app, duplicated by hand).

## Background / reality check

The initial framing of this initiative ("10 calls/user/min") does not match the deployed backend:

- `the_vaults_backend`'s `ThrottlerModule` is configured for **100 requests/minute**, keyed by the default NestJS tracker (**client IP**, not authenticated user). See `src/app.module.ts` — a comment there records that the limit was already raised from 10/30s because legitimate single-screen loads couldn't stay under it.
- `the_vaults_customer` already has partial 429 handling: `ErrorInterceptor` maps 429 → `RateLimitException` → `RateLimitFailure`, and a dedicated `RateLimitErrorWidget` shows a countdown ("High Demand" / "Your items are safe in your cart"). There is currently **no retry logic** — every 429 goes straight to the UI.
- `the_vaults_vendor` has **no 429-specific handling at all** — a 429 falls through to a generic `ServerException`.
- Neither app has a telemetry/analytics SDK today (no Sentry, Firebase, Mixpanel). Neither has Riverpod — both use `flutter_bloc` + `get_it` + `go_router` + `flutter_flavor`.
- The backend has no generic idempotency-key mechanism for cart/order mutations (only external-provider idempotency for BinGold payments). That gap is deliberately out of scope here — mutation safety is sub-project 4, client-side only per decision below.

## Goals

1. Give both apps a typed, non-UI-coupled way to detect and react to 429s.
2. Absorb short throttling blips silently; never auto-retry in a way that could double-submit a mutation.
3. Get visibility (via Sentry) into how often real users hit the limit, on which endpoint/screen, and whether a silent retry saved the request — before investing further in caching (sub-project 2) or idempotency (sub-project 4).

## Non-goals (explicitly deferred)

- No caching or in-flight GET deduplication (sub-project 2).
- No idempotency keys or backend changes for mutation retries (sub-project 4). Mutations that hit 429 fail fast, always, in this sub-project.
- No shared Dart package between the two apps — decided to duplicate the implementation per app to avoid new cross-repo tooling.
- No new "High Demand"-style dedicated widget for the vendor app in this sub-project — vendor reuses its existing generic error widget for `RateLimitFailure` for now.

## Components (per app)

### `RateLimitException` / `RateLimitFailure`
- Vendor: new, matching the shape already in `the_vaults_customer/lib/core/error/exceptions.dart` and `failures.dart` (message + optional `retryAfterSeconds`).
- Customer: existing types, unchanged.

### `CurrentScreenTracker`
- New singleton (per app) holding the current route name as a plain string.
- Updated by a `NavigatorObserver` registered on the app's `GoRouter` (`didPush`/`didPop`/`didReplace` update the tracked name from `GoRouterState`/route settings).
- Read synchronously by the interceptor — Dio has no `BuildContext`, so this avoids threading a "screen" tag through every call site.

### `RateLimitInterceptor`
- Replaces the inline 429 branch in `ErrorInterceptor` (customer) / adds equivalent handling (vendor). Still lives in the Dio interceptor chain; still never touches UI — it resolves to a typed exception/failure exactly like other error branches, same as the existing pattern.
- Responsibilities: read `Retry-After`, apply the retry policy below, emit the Sentry event, and — if not retried or retry also failed — pass a `RateLimitException` down the existing exception → failure pipeline unchanged.

### Retry policy

| Request type | `Retry-After` ≤ 5s | `Retry-After` > 5s | No `Retry-After` header |
|---|---|---|---|
| GET | wait, retry once, silently | fail fast (typed failure surfaces immediately) | backoff from 1s + jitter; retry once only if the projected wait keeps total ≤5s, else fail fast |
| POST / PUT / DELETE | **never auto-retry** | fail fast | fail fast |

- If the single silent GET retry also returns 429, fail fast — no second retry, no unbounded loop.
- The 5-second ceiling is a hard wall-clock budget for the *whole* interceptor-level wait, not per-attempt.

### Sentry integration
- Added to both apps via `SentryFlutter.init(...)` wrapping `runApp` inside each app's `bootstrap()`.
- DSN sourced from `FlavorConfig.instance.variables['sentryDsn']`, added as an empty string in each flavor's `main_*.dart` for now. An empty DSN makes the SDK a no-op — safe to ship before real DSNs exist, and swapping in a real DSN later needs no code change.

### Telemetry event
Emitted from the interceptor (not from UI) on every 429, whether or not a retry was attempted, and on every mutation that fails fast due to 429:

```
rate_limited: {
  endpoint: string,       // request path
  method: string,
  screen: string,         // from CurrentScreenTracker
  retryAfterSeconds: int?,
  retryAttempted: bool,
  retrySucceeded: bool?,  // null if not attempted
}
```

## What changes, file by file

**Vendor** (`the_vaults_vendor`):
- `lib/core/error/exceptions.dart` — add `RateLimitException`.
- `lib/core/error/failures.dart` — add `RateLimitFailure`.
- `lib/core/api/interceptors/error_interceptor.dart` — add 429 branch calling into the new `RateLimitInterceptor` retry policy.
- `lib/core/api/interceptors/` — new `rate_limit_interceptor.dart` (or inline logic, depending on how the existing interceptor is structured — decide during implementation) implementing the retry table above.
- New `lib/core/services/current_screen_tracker.dart` + `NavigatorObserver` wired into `app_router.dart`.
- `lib/main_dev.dart` / `main_staging.dart` / `main_prod.dart` — add `'sentryDsn': ''`.
- `lib/app/bootstrap.dart` (or equivalent) — wrap `runApp` with `SentryFlutter.init`.
- `pubspec.yaml` — add `sentry_flutter`.
- Existing generic error widget — no new widget, just confirm it renders `RateLimitFailure` reasonably (message + retry button).

**Customer** (`the_vaults_customer`):
- `lib/core/api/interceptors/error_interceptor.dart` — extract the existing inline 429 branch into the same retry-policy logic (currently has no retry at all).
- New `lib/core/services/current_screen_tracker.dart` + observer wired into `app_router.dart`.
- `lib/main_dev.dart` / `main_staging.dart` / `main_prod.dart` — add `'sentryDsn': ''`.
- `lib/app/bootstrap.dart` — wrap `runApp` with `SentryFlutter.init`.
- `pubspec.yaml` — add `sentry_flutter`.
- `RateLimitErrorWidget` — unchanged.

## Testing

- Unit tests for the retry-policy decision function (pure function: given status/headers/request-method/elapsed-budget → retry-or-not), covering: short `Retry-After` GET (retries), long `Retry-After` GET (fails fast), missing header GET (backoff-then-decide), any mutation (never retries).
- Interceptor tests using a mock Dio adapter returning 429 then 200, verifying exactly one silent retry for GET and zero for mutations.
- Verify Sentry event payload shape via a fake `Sentry` transport/mock in tests (no real network calls in tests).
- Manual verification: temporarily lower `THROTTLE_LIMIT`/`THROTTLE_TTL_MS` on a local backend to trigger real 429s, confirm both apps behave per the table above and Sentry receives events (once a real DSN is in place).

## Acceptance criteria

- A 429 on a GET with `Retry-After` ≤5s is invisible to the user in the common case (silent retry succeeds).
- A 429 on a GET with a longer wait or on any mutation surfaces the existing typed failure through the existing UI path, unchanged from today's behavior — no double-submission risk introduced.
- Every 429 (retried or not) produces exactly one Sentry event with the schema above.
- Vendor app's behavior on 429 is no longer "generic server error" — it's a recognized `RateLimitFailure`.
- No client-side sliding-window rate counter is introduced.
