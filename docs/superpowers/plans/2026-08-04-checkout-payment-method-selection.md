# Checkout Payment Method Selection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let customers actually choose between Bingold Wallet and Cash on Delivery on the Review & Pay screen — the enum/cubit/`makePayment()` logic already supports both, but no UI has ever called `selectPaymentMethod()`.

**Architecture:** A new bottom-sheet widget (`showPaymentMethodPicker`), reached by tapping "Change" on the existing `ReviewPaymentCard`, calls the existing `PaymentMethodCubit.selectPaymentMethod()`. `ReviewPaymentCard` and `PayNowBottomBar` gain small new params to reflect the selected method and correct the pay-button label.

**Tech Stack:** Flutter, `flutter_bloc` (existing `PaymentMethodCubit`, unchanged).

## Global Constraints

- Only two `PaymentMethod` values are exposed in the picker: `wallet` (Bingold Wallet) and `cashOnDelivery`. The other 5 enum values (`upi`, `creditDebit`, `card`, `payLater`, `bingoldWallet`) are not shown — no gateway integration exists for them, confirmed in the spec.
- No backend changes.
- No new automated test suite — this app has none for the payment feature. Each task's verification step is `flutter analyze` on the touched files; the final task is a manual run-through, per the approved spec's Testing section.
- Follow this repo's existing conventions exactly: bottom-sheet picker style matches `_SortSheet` in `lib/features/product_categories_details/presentation/widgets/filter_bar.dart` (title + `ListTile` rows + checkmark `trailing`), new widget file goes in `lib/features/payment/presentation/screens/widgets/` (the existing sibling directory that already holds `payment_progress_stepper.dart`, `success_action_bar.dart`, etc.), relative imports (`'widgets/payment_method_picker.dart'`) matching how `payment_screen.dart` already imports its sibling widgets.

Every task's requirements implicitly include the above.

---

### Task 1: Payment method picker widget

**Files:**
- Create: `lib/features/payment/presentation/screens/widgets/payment_method_picker.dart`

**Interfaces:**
- Consumes: `PaymentMethod` enum and `PaymentMethodCubit` (both existing, from `../../cubit/payment_state.dart` and `../../cubit/payment_cubit.dart`).
- Produces: `Future<void> showPaymentMethodPicker(BuildContext context, PaymentMethod selected)`. Task 2 calls this exact function with this exact signature.

- [ ] **Step 1: Write the picker widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../cubit/payment_cubit.dart';
import '../../cubit/payment_state.dart';

Future<void> showPaymentMethodPicker(
  BuildContext context,
  PaymentMethod selected,
) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _PaymentMethodSheet(
      selected: selected,
      onSelect: (method) {
        Navigator.pop(sheetContext);
        context.read<PaymentMethodCubit>().selectPaymentMethod(method);
      },
    ),
  );
}

class _PaymentMethodSheet extends StatelessWidget {
  final PaymentMethod selected;
  final void Function(PaymentMethod) onSelect;

  const _PaymentMethodSheet({required this.selected, required this.onSelect});

  static const _options = [
    (PaymentMethod.wallet, Icons.account_balance_wallet_outlined, 'Bingold Wallet'),
    (PaymentMethod.cashOnDelivery, Icons.payments_outlined, 'Cash on Delivery'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment method', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          ..._options.map(
            (opt) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(opt.$2, color: ThemeColors.blue),
              title: Text(opt.$3, style: AppTextStyles.bodyMedium),
              trailing: selected == opt.$1
                  ? const Icon(Icons.check, color: ThemeColors.blue)
                  : null,
              onTap: () => onSelect(opt.$1),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify with the analyzer**

Run: `cd the_vaults_customer && flutter analyze lib/features/payment/presentation/screens/widgets/payment_method_picker.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/payment/presentation/screens/widgets/payment_method_picker.dart
git commit -m "feat: add payment method picker bottom sheet"
```

---

### Task 2: Wire the picker into Review & Pay

**Files:**
- Modify: `lib/features/payment/presentation/screens/review_pay_screen.dart`

**Interfaces:**
- Consumes: `showPaymentMethodPicker` (Task 1), `PaymentMethodCubit`/`PaymentMethodState`/`PaymentMethod` (existing).
- Produces: `ReviewPaymentCard` gains `selectedMethod` (`PaymentMethod`, required) and `onChangeTap` (`VoidCallback`, required) params. `PayNowBottomBar` gains `buttonLabel` (`String`, required). No other file depends on these signatures — `ReviewPayScreen` is their only caller, updated in this same task so the file stays compilable throughout.

- [ ] **Step 1: Add the import**

At the top of `review_pay_screen.dart`, add (alongside the existing `import 'widgets/payment_progress_stepper.dart';`-style relative imports used elsewhere in this feature — check `payment_screen.dart` for the exact pattern if unsure):

```dart
import 'widgets/payment_method_picker.dart';
```

- [ ] **Step 2: Add params and the "Change" button to `ReviewPaymentCard`**

Find:
```dart
class ReviewPaymentCard extends StatelessWidget {
  const ReviewPaymentCard({
    super.key,
    required this.methodName,
    required this.bigoldBalance,
  });

  final String methodName;
  final String bigoldBalance;
```
Replace with:
```dart
class ReviewPaymentCard extends StatelessWidget {
  const ReviewPaymentCard({
    super.key,
    required this.methodName,
    required this.bigoldBalance,
    required this.selectedMethod,
    required this.onChangeTap,
  });

  final String methodName;
  final String bigoldBalance;
  final PaymentMethod selectedMethod;
  final VoidCallback onChangeTap;
```

Find the gradient header's `Row` (it currently ends with the "Secured" pill `Container` as its last child, directly before the header `Container`'s closing):
```dart
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 15,
                        color: ThemeColors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secured',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: ThemeColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
```
Replace with (adds a "Change" text button after the Secured pill):
```dart
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 15,
                        color: ThemeColors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secured',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: ThemeColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onChangeTap,
                  style: TextButton.styleFrom(
                    foregroundColor: ThemeColors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Change',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: ThemeColors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
```

Find the balance section:
```dart
          // ── Balance ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR BALANCE',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: ThemeColors.inkMid,
                  ),
                ),
                const SizedBox(height: 12),
                _BalanceRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Bigod Balance',
                  value: bigoldBalance,
                  color: const Color(0xFFF7A928),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```
Replace with (balance row only for wallet; a plain COD message otherwise):
```dart
          // ── Balance (wallet only) / COD note ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(18),
            child: selectedMethod == PaymentMethod.wallet
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR BALANCE',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: ThemeColors.inkMid,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _BalanceRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Bigod Balance',
                        value: bigoldBalance,
                        color: const Color(0xFFF7A928),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 18,
                        color: ThemeColors.inkMid,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pay with cash when your order arrives',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: ThemeColors.inkMid,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Add `buttonLabel` to `PayNowBottomBar`**

Find:
```dart
class PayNowBottomBar extends StatelessWidget {
  const PayNowBottomBar({
    super.key,
    required this.amount,
    required this.isLoading,
    required this.onPay,
  });

  final String amount;
  final bool isLoading;
  final VoidCallback onPay;
```
Replace with:
```dart
class PayNowBottomBar extends StatelessWidget {
  const PayNowBottomBar({
    super.key,
    required this.amount,
    required this.buttonLabel,
    required this.isLoading,
    required this.onPay,
  });

  final String amount;
  final String buttonLabel;
  final bool isLoading;
  final VoidCallback onPay;
```

Find:
```dart
              label: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Pay $amount', style: AppTextStyles.buttonText),
```
Replace with:
```dart
              label: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('$buttonLabel $amount', style: AppTextStyles.buttonText),
```

- [ ] **Step 4: Wire both widgets from `ReviewPayScreen.build()`**

Find:
```dart
            bottomNavigationBar: PayNowBottomBar(
              amount: state.formattedTotal,
              isLoading: state.isProcessing,
```
Replace with:
```dart
            bottomNavigationBar: PayNowBottomBar(
              amount: state.formattedTotal,
              buttonLabel: state.selectedMethod == PaymentMethod.cashOnDelivery
                  ? 'Place Order'
                  : 'Pay Now',
              isLoading: state.isProcessing,
```

Find:
```dart
                  // ── Paying With ───────────────────────────────────────
                  ReviewPaymentCard(
                    methodName: state.methodDisplayName,
                    bigoldBalance: state.formattedBigoldBalance,
                  ),
```
Replace with:
```dart
                  // ── Paying With ───────────────────────────────────────
                  ReviewPaymentCard(
                    methodName: state.methodDisplayName,
                    bigoldBalance: state.formattedBigoldBalance,
                    selectedMethod: state.selectedMethod,
                    onChangeTap: () =>
                        showPaymentMethodPicker(context, state.selectedMethod),
                  ),
```

- [ ] **Step 5: Verify with the analyzer**

Run: `cd the_vaults_customer && flutter analyze lib/features/payment/presentation/screens/review_pay_screen.dart lib/features/payment/presentation/screens/widgets/payment_method_picker.dart`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/payment/presentation/screens/review_pay_screen.dart
git commit -m "feat: wire payment method picker into Review & Pay screen"
```

---

### Task 3: Manual verification pass

**Files:** none (verification only).

**Interfaces:** none — this task exercises Tasks 1–2 end to end.

- [ ] **Step 1: Static check across the whole feature**

Run: `cd the_vaults_customer && flutter analyze`
Expected: only the same pre-existing issues present before this change (there is no automated baseline file — compare by running `flutter analyze` on `main`/`customer_ui` before these commits if anything unexpected shows up).

- [ ] **Step 2: Run the app and reach Review & Pay**

Run the app, log in, add an item to cart or use Buy Now, fill in a delivery address, continue to Review & Pay.

- [ ] **Step 3: Verify the default state**

Confirm `ReviewPaymentCard` shows "Bingold Wallet" with the Bigod balance row, and the pay button reads "Pay Now $amount".

- [ ] **Step 4: Verify the picker**

Tap "Change". Confirm the bottom sheet shows both "Bingold Wallet" (checked) and "Cash on Delivery" (unchecked), styled like the existing sort-by sheet.

- [ ] **Step 5: Verify switching to Cash on Delivery**

Tap "Cash on Delivery". Confirm the sheet closes, the card now shows "Cash on Delivery", the balance row is replaced by "Pay with cash when your order arrives", and the pay button now reads "Place Order $amount".

- [ ] **Step 6: Complete a COD order**

Tap "Place Order". Confirm it reaches `payment_success_screen.dart` (via `_placeCodOrder()` — no BIGOD intent/confirm call should appear in the network logs for this path).

- [ ] **Step 7: Complete a Wallet order**

Repeat from Step 2, this time leaving the method on Bingold Wallet (or switching back to it via "Change"), and confirm payment still completes via the BIGOD intent/confirm flow exactly as before this change.

- [ ] **Step 8: Final commit (if any fixups were needed)**

If any manual step above surfaced a bug, fix it, re-run the relevant analyzer command from that task, then:

```bash
git add -A
git commit -m "fix: address issues found during payment method selection verification"
```

If nothing needed fixing, no commit is required for this task.

---

## Self-Review

**Spec coverage:** Only-2-methods restriction (Global Constraints + Task 1's `_options`), picker location on Review & Pay only (Task 2), COD always available/no restrictions (no eligibility check added anywhere, matching the spec), `_SortSheet` visual precedent (Task 1), conditional balance section (Task 2 Step 2), pay-button label fix (Task 2 Step 3–4) — every spec decision has a task.

**Placeholder scan:** No TBD/TODO; every step has complete, runnable code or an exact find/replace block.

**Type consistency:** `showPaymentMethodPicker(BuildContext, PaymentMethod)` in Task 1 matches exactly how Task 2 Step 4 calls it. `ReviewPaymentCard`'s new `selectedMethod`/`onChangeTap` and `PayNowBottomBar`'s new `buttonLabel` are defined and consumed within the same task (Task 2), so there's no cross-task signature drift to check.
