---
name: wallet-checkout-bigod-migration
description: Migrate Buy Now / Cart wallet checkout from the internal balance-operation endpoint to the backend's BIGOD intent/confirm flow; fix COD wallet-debit bug; retire dead checkout code
metadata:
  type: project
---

# Wallet Checkout → BIGOD Intent/Confirm Migration Design

**Date:** 2026-08-03
**Repos:** `the_vaults_customer` (Flutter, this repo) + `the_vaults_backend` (NestJS, branch `aditya`)
**Related:** Spec 2 (not yet written) will replace the scanner's disabled P2P "pay any amount" screen with vendor-scoped shopping.

## Background

The app's wallet checkout (Buy Now and Cart) currently calls `POST /api/v1/customers/bingopay/balance/operation` directly from the client to debit the buyer and credit the vendor, using a hardcoded API key (`x-api-key: mysecreate-key`) and a hardcoded IP base URL. That endpoint is guarded only by `InternalApiKeyGuard` — a static shared secret, not the caller's JWT — and was built for server-to-server use, not a public mobile client. The same key is baked into the shipped app binary and is trivially extractable, letting anyone move BinGold balances for arbitrary accounts with no identity check.

Separately, wallet debit and order creation are two independent network calls with no shared transaction: if order creation (`/api/v1/checkout` or `/api/v1/orders`) fails after the debit succeeds, the app swallows the error and fabricates a synthetic order ID (`BG-<timestamp>`) so the UI still shows success — money moves with no real order behind it. Cash-on-Delivery selection is also ignored: `makePayment()` always runs the wallet-debit path regardless of `selectedMethod`.

The backend already has a purpose-built, atomic flow for this — `POST /api/v1/payments/bigod/intent` and `POST /api/v1/payments/bigod/confirm` — that the app never adopted. This spec migrates the app to it.

## Architecture

```
WALLET (Buy Now or Cart)
  app -> POST /api/v1/payments/bigod/intent   { addressId, variantUuid?, quantity? }
  app <- { token, amount, breakdown, vendors[], customerBalance, expiresAt }
  app -> POST /api/v1/payments/bigod/confirm  { token }
  app <- { status: PAID, order: { uuid, orderNumber }, balance }

COD (Buy Now or Cart)
  app -> POST /api/v1/orders  { addressId, paymentMethod: 'COD', variantUuid?, quantity? }
  app <- order (immediately CONFIRMED, no payment leg)
```

Both endpoints are JWT-authenticated (`ApiClient`'s existing Bearer interceptor) — no API key, no manual header juggling. Confirmed via `order.service.ts`: omitting `variantUuid` already makes `/api/v1/orders` build the order from the caller's full active cart, so it needs no changes to support COD-cart. `/api/v1/checkout` (the only other cart→order path) is redundant and is being deleted (see Backend Changes).

## Customer App Changes

| File | Change |
|---|---|
| `lib/features/payment/data/bigod_payment_datasource.dart` (new) | Dio calls via the shared `ApiClient` for `/payments/bigod/intent` and `/payments/bigod/confirm`; typed request/response models for both. |
| `lib/features/payment/presentation/cubit/payment_cubit.dart` | Rewrite `makePayment()`: branch on `state.selectedMethod`. `wallet`/`bingoldWallet` → intent then confirm; `cashOnDelivery` → `/api/v1/orders` directly, no balance call. Delete `_apiUrl`, `_apiKey`, `_resolveVendorEmail`, `_checkout()`, the synthetic order-id fallback, and the swallowed-exception `catch (_) { return null; }` blocks. |
| `lib/features/payment/presentation/cubit/payment_state.dart` | Add `customerBalance` and `breakdown` (subtotal/tax/shipping/total) from the intent response, displayed on the review screen in place of the client-computed totals used today; `orderId` now always comes from a real `order.orderNumber`. |
| `lib/features/payment/presentation/screens/review_pay_screen.dart` | No structural change — same `onPay` → `makePayment()` → branch on `PaymentStatus`. Remove the commented-out dead screen at the top of the file (lines 1-291) while touching it. |
| `lib/core/api/api_endpoints.dart` | Add `bigodIntent = '/api/v1/payments/bigod/intent'` and `bigodConfirm = '/api/v1/payments/bigod/confirm'`. Delete the `scanner` constant — it only ever pointed at the internal balance-operation endpoint; Spec 2 will add its own `resolve-token` constant when it builds the vendor-scoped flow. |
| Cart clear | Call the existing (currently unused) `ClearCartUseCase` after a successful WALLET or COD cart order, before navigating to the success screen. |
| `lib/features/scanner/presentation/screens/payment_screen.dart` (`ReviewPaymentScreen`) | Replace the `_pay()` action with a disabled/"temporarily unavailable" state. This flow has no backend equivalent (freeform P2P transfer isn't a real BIGOD operation) and its only backend dependency is the key being rotated away. Full replacement is Spec 2. |
| `lib/features/scanner/data/datasource/payment_remote_datasource.dart`, `payment_cubit.dart` (payment feature) | Remove the hardcoded `mysecreate-key` / IP literals entirely. |

Error handling: map backend error responses to specific messages instead of one generic string — 400 on intent (insufficient balance, out of stock, vendor not approved, self-pay) and on confirm (BinGold refused, expired token); 409 on confirm (already used — treat as "already processed," not a failure); 403/404 (wrong account / invalid token). The existing "disable Pay button while processing" guard stays; the backend's single-use token makes a duplicate confirm call safe regardless.

## Backend Changes (branch `aditya`)

| Change | Detail |
|---|---|
| Delete `src/modules/checkout/` | `checkout.controller.ts`, `checkout.service.ts`, `checkout.module.ts`, `dto/`. Verified: `CheckoutModule`/`CheckoutService`/`CheckoutController` are referenced nowhere outside their own folder except `app.module.ts`'s registration. |
| `src/app.module.ts` | Remove the `CheckoutModule` import and its entry in the module list. |
| `.env` | Rotate `INTERNAL_API_KEY` to a new random value. Nothing in the app references it after this change; this only invalidates the leaked value for any other internal caller. **Note:** this repo's `.env` is local/gitignored — whoever manages the actual deployed server's environment needs to apply the same new value there and restart the service for the rotation to take effect in production. |

## Out of Scope (deferred to Spec 2 or later)

- Rebuilding the scanner flow as vendor-scoped shopping (scan QR → resolve vendor → browse their catalog via `GET /products?vendorUuid=` → checkout via this spec's WALLET flow).
- UPI, Credit/Debit Card, Pay Later payment methods — not functionally wired today either; this spec doesn't regress or improve them.
- Razorpay flow (`/payments/create-order` + `/payments/verify`) — untouched, already gateway-based and independent of this change.
- A reconciliation job for the BIGOD `RECONCILING` state — pre-existing gap in the backend, not introduced or fixed here.

## Testing

- Backend: existing Jest suite, including `bigod-payment.mixed-basket.spec.ts`; add coverage for the deleted checkout module's absence not breaking `app.module.ts` bootstrap.
- Customer app: `flutter analyze`; no emulator/device available in this environment, so manual verification against `bingo_pay_test_cases.csv` rows TC-CHK-003/004/005, TC-PAY-003/004, TC-WAL-003 is needed on your side before release.
