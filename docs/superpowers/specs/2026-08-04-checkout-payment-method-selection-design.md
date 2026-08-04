---
name: checkout-payment-method-selection
description: Let customers actually choose Bingold Wallet vs Cash on Delivery in checkout — the selector UI never existed, so selectedMethod was permanently stuck at wallet and COD was unreachable
metadata:
  type: project
---

# Checkout Payment Method Selection Design

**Date:** 2026-08-04
**Repo:** `the_vaults_customer` (Flutter)

## Background

`PaymentMethod` enum, `PaymentMethodCubit.selectPaymentMethod()`, and distinct `makePayment()` branches for Cash on Delivery vs Bingold Wallet (BIGOD intent/confirm — see `2026-08-03-wallet-checkout-bigod-migration-design.md`) all already exist and work correctly. But nothing in the UI ever calls `selectPaymentMethod()`. `PaymentMethodState.initial()` hardcodes `selectedMethod: PaymentMethod.wallet`, and `review_pay_screen.dart`'s `ReviewPaymentCard` only *displays* `state.methodDisplayName` — no `onTap`, no picker, nothing. Cash on Delivery, despite having real backend logic, is currently unreachable by any customer.

Of the 7 `PaymentMethod` enum values, only two have real, distinct execution paths in `makePayment()` today:
- `wallet` (displayed "Bingold Wallet") → BIGOD intent/confirm flow.
- `cashOnDelivery` → `POST /orders` with `paymentMethod: 'COD'`, no payment gateway.

`upi`, `creditDebit`/`card`, `payLater`, and `bingoldWallet` (a duplicate-meaning value alongside `wallet`) have display names but no distinct logic — selecting them would silently run the BIGOD wallet flow, which is wrong (BIGOD is a crypto-token payment, not a real UPI/card/pay-later gateway, and none of those gateways are integrated anywhere in this codebase).

## Decisions confirmed with user

- The picker shows **only the two real methods** — Bingold Wallet and Cash on Delivery. The other 5 enum values stay unused/unexposed until real gateways exist; no "Coming soon" placeholders.
- Picker lives on **`review_pay_screen.dart`** only, reached by tapping "Change" on `ReviewPaymentCard` — not duplicated onto the earlier `payment_screen.dart` (address) step.
- Cash on Delivery is **unconditionally available**, same as Wallet — no order-value cap, no cart-vs-single-item restriction (matches the backend, which has no COD eligibility checks).
- Visual style matches the existing `_SortSheet` bottom-sheet pattern in `filter_bar.dart` (title + `ListTile` rows + checkmark for the selected option) rather than inventing a new picker style.

## Design

### New file: `lib/features/payment/presentation/widgets/payment_method_picker.dart`

```dart
Future<void> showPaymentMethodPicker(BuildContext context, PaymentMethod selected);
```
Opens a `showModalBottomSheet` (rounded top corners, matching `_SortSheet`'s `shape`) containing a private `_PaymentMethodSheet` — two `ListTile` rows (Bingold Wallet / Cash on Delivery, each with a leading icon), a checkmark `trailing` icon on whichever matches `selected`. Tapping a row pops the sheet and calls `context.read<PaymentMethodCubit>().selectPaymentMethod(method)` — no new cubit logic needed, `selectPaymentMethod` already does exactly the right thing.

### `ReviewPaymentCard` (in `review_pay_screen.dart`)

- New params: `selectedMethod` (the `PaymentMethod` enum, not just the display string it already receives) and `onChangeTap` (`VoidCallback`).
- Header gains a small "Change" text button next to the existing "Secured" pill, calling `onChangeTap`.
- The "YOUR BALANCE" / Bigod Balance row becomes conditional: shown only when `selectedMethod == PaymentMethod.wallet`. For `cashOnDelivery`, replaced with a single line — "Pay with cash when your order arrives" — since a wallet balance is irrelevant to COD.
- `ReviewPayScreen.build()` passes `selectedMethod: state.selectedMethod` and `onChangeTap: () => showPaymentMethodPicker(context, state.selectedMethod)`.

### `PayNowBottomBar` (same file)

- New param `buttonLabel` (`String`), replacing the currently-hardcoded pay-button text.
- `ReviewPayScreen.build()` computes it: `state.selectedMethod == PaymentMethod.cashOnDelivery ? 'Place Order' : 'Pay Now'` — COD doesn't take payment at this step, so "Pay Now" is factually wrong for it.
- No change to `onPay`'s logic — `makePayment()` already branches correctly on `selectedMethod`; this is a label-only fix.

### Out of scope

- The 5 unimplemented `PaymentMethod` values (`upi`, `creditDebit`, `card`, `payLater`, `bingoldWallet`) — no gateway integration, no picker entries, no `makePayment()` branches added for them.
- Any change to `payment_screen.dart` (the address-selection step) — method selection is scoped to `review_pay_screen.dart` only.
- COD eligibility rules of any kind (order value caps, category restrictions) — none exist today and none are being added.

### Testing

No automated test suite exists for the payment feature today (consistent with the rest of this app — see prior specs). Verification is manual: open Review & Pay, confirm the card defaults to Bingold Wallet, tap "Change", confirm both options are listed with the correct one checked, switch to Cash on Delivery, confirm the balance row is replaced by the COD message and the pay button now reads "Place Order", complete a COD order, then repeat switching back to Wallet and completing a wallet order — both should reach `payment_success_screen.dart` correctly.
