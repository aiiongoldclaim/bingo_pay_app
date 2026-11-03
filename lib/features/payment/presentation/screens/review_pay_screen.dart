import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../address/domain/entities/address_entity.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';
import '../../../scanner/presentation/screens/wallet_mpin_screen.dart';
import '../../../scanner/presentation/widgets/review_payment_metrics.dart';
import '../../../scanner/presentation/widgets/review_payment_note_section.dart';
import '../../../tvs_wallet/presentation/widgets/tvs_format.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/checkout_ui.dart';
import '../widgets/tvs_checkout_offers.dart';
import 'payment_flow_args.dart';

// Checkout, step 2: where it goes, how to pay, and what it comes to.
class ReviewPayScreen extends StatelessWidget {
  final bool isCart;
  const ReviewPayScreen({super.key, required this.isCart});

  // Another saved address; the prices are worked out again for it.
  Future<void> _changeAddress(BuildContext context) async {
    final cubit = context.read<PaymentMethodCubit>();
    final picked = await context.push<AddressEntity>(
      AppRoutes.addressList,
      extra: cubit.state.deliveryAddressId,
    );
    if (picked == null) return;
    cubit
      ..updateDeliveryAddress(
        name: picked.fullName,
        phone: picked.phoneNumber,
        address: picked.addressLine1,
        city: picked.city,
        postal: picked.postalCode,
        addressId: picked.id,
      )
      ..loadQuote()
      ..loadTvsQuote();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      builder: (context, state) {
        final cubit = context.read<PaymentMethodCubit>();
        final selected = state.selectedMethod ?? PaymentMethod.wallet;
        final methods = [
          (
            PaymentMethod.wallet,
            Icons.account_balance_wallet_outlined,
            'Bingold Wallet',
            'Balance: ${state.formattedBigoldBalance}',
          ),
          if (state.tvsAvailable)
            (
              PaymentMethod.tvsWallet,
              Icons.toll_rounded,
              'TVS Wallet',
              _tvsSubtitle(state.tvsQuote),
            ),
          if (state.cardAvailable)
            (
              PaymentMethod.card,
              Icons.credit_card_outlined,
              'Credit / debit card',
              "Pay on Stripe's secure page",
            ),
          if (state.cryptoAvailable)
            (
              PaymentMethod.crypto,
              Icons.currency_bitcoin,
              'Crypto',
              'BTC, ETH, USDT and more, priced in USD',
            ),
          (
            PaymentMethod.cashOnDelivery,
            Icons.payments_outlined,
            'Cash on delivery',
            'Pay when your order arrives',
          ),
        ];

        final total = state.isQuoted ? money(state.totalAmount) : null;
        final coins = state.tvsQuote?['coins'] as Map?;
        final label = switch (selected) {
          PaymentMethod.tvsWallet =>
            coins == null
                ? 'Pay with TVS Coins'
                : 'Pay ${tvsCoins(coins['total'], coins['currency'])} with TVS Coins',
          PaymentMethod.cashOnDelivery =>
            total == null ? 'Place order' : 'Place order · $total',
          PaymentMethod.card => 'Continue to card payment',
          PaymentMethod.crypto => 'Continue to crypto payment',
          _ => total == null ? 'Pay now' : 'Pay $total',
        };
        final extras = [
          if (state.savings > 0)
            CheckoutLine(
              'Savings',
              '− ${money(state.savings)}',
              color: colors.statusSuccess,
            ),
          if (state.isQuoted && state.deliveryCharge > 0)
            CheckoutLine('Delivery', money(state.deliveryCharge)),
          if (state.isQuoted && state.taxes > 0)
            CheckoutLine('Taxes & fees', money(state.taxes)),
        ];
        // TVS Wallet can't pay until its quote says so, nor while the MPIN
        // it needs is locked.
        final tvsPin = state.tvsQuote?['pin'] as Map?;
        final blocked =
            selected == PaymentMethod.tvsWallet &&
            (state.tvsQuote?['canPay'] != true ||
                (tvsPin?['required'] == true &&
                    tvsPin?['lockedUntil'] != null));

        return Scaffold(
          backgroundColor: colors.background,
          appBar: const CustomAppBar(title: 'Review & Pay'),
          body: Column(
            children: [
              Expanded(
                child: CheckoutBody(
                  children: [
                    if (state.deliveryName.isNotEmpty) ...[
                      CheckoutSection(
                        title: 'Deliver to',
                        action: TextButton(
                          onPressed: () => _changeAddress(context),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Change'),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.place_outlined,
                              color: colors.brand,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.deliveryName,
                                    style: checkoutText(
                                      colors.textPrimary,
                                      size: 15,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${state.deliveryAddress}, ${state.deliveryCity} ${state.deliveryPostal}',
                                    style: checkoutText(
                                      colors.textSecondary,
                                      size: 13,
                                    ),
                                  ),
                                  Text(
                                    state.deliveryPhone,
                                    style: checkoutText(
                                      colors.textMuted,
                                      size: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    CheckoutSection(
                      title: 'Pay with',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, (method, icon, title, subtitle))
                              in methods.indexed) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: colors.border,
                              ),
                            _MethodRow(
                              icon: icon,
                              title: title,
                              subtitle: subtitle,
                              selected: selected == method,
                              onTap: () => cubit.selectPaymentMethod(method),
                            ),
                            if (method == PaymentMethod.tvsWallet &&
                                selected == method) ...[
                              TvsQuoteFix(
                                quote: state.tvsQuote,
                                onBack: cubit.loadTvsQuote,
                              ),
                              if (state.tvsQuote?['coins'] != null)
                                TvsCheckoutOffers(quote: state.tvsQuote!),
                            ],
                          ],
                        ],
                      ),
                    ),
                    // Buy Now paid on delivery can carry a coupon and a note.
                    if (!state.isCartFlow &&
                        selected == PaymentMethod.cashOnDelivery) ...[
                      const SizedBox(height: 12),
                      const _CouponAndNote(),
                    ],
                    const SizedBox(height: 20),
                    CheckoutSection(
                      title: 'Order summary',
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      child: Column(
                        children: [
                          CheckoutItems(state: state),
                          // Item total only when something is added to it.
                          if (extras.isNotEmpty) ...[
                            Divider(height: 20, color: colors.border),
                            CheckoutLine('Item total', money(state.itemTotal)),
                            ...extras,
                          ],
                          Divider(height: 20, color: colors.border),
                          CheckoutLine(
                            'Total',
                            total ?? 'At payment',
                            total: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CheckoutBar(
                label: label,
                isLoading: state.isProcessing,
                onPressed: blocked ? null : () => _onPay(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Payment logic ─────────────────────────────────────────────────────
  Future<void> _onPay(BuildContext context) async {
    final cubit = context.read<PaymentMethodCubit>();

    // Card payments finish on Stripe's page, not here: the card screen takes
    // over and moves on to the success screen once the server reports PAID.
    // Crypto payments do the same on NOWPayments' page.
    final method = cubit.state.selectedMethod;
    if (method == PaymentMethod.tvsWallet) return _payWithTvs(context, cubit);
    if (method == PaymentMethod.card || method == PaymentMethod.crypto) {
      final isCrypto = method == PaymentMethod.crypto;
      final intent = isCrypto
          ? await cubit.startCryptoPayment()
          : await cubit.startCardPayment();

      if (!context.mounted) return;

      if (intent == null) {
        AppSnackbar.showError(
          context,
          cubit.state.errorMessage ?? 'Payment failed. Please try again.',
        );
        return;
      }

      context.push(
        AppRoutes.paymentCard,
        extra: CardPaymentArgs(
          cubit: cubit,
          intent: intent,
          isCrypto: isCrypto,
        ),
      );
      return;
    }

    await cubit.makePayment();

    if (!context.mounted) return;

    if (cubit.state.status == PaymentStatus.success) {
      context.pushReplacement(AppRoutes.paymentSuccess, extra: cubit);
    } else if (cubit.state.status == PaymentStatus.failure) {
      AppSnackbar.showError(
        context,
        cubit.state.errorMessage ?? 'Payment failed. Please try again.',
      );
    }
  }

  // TVS Wallet: pays the quoted coins, through the MPIN screen when the
  // amount is over the PIN-free limit (creating an MPIN if there is none).
  Future<void> _payWithTvs(
    BuildContext context,
    PaymentMethodCubit cubit, {
    bool? needsPin,
    bool? isSet,
  }) async {
    final quote = cubit.state.tvsQuote;
    if (quote?['canPay'] != true) {
      AppSnackbar.showError(
        context,
        '${quote?['reason'] ?? 'Your TVS Coins are still being checked.'}',
      );
      return;
    }
    final pin = quote?['pin'] as Map?;
    final coins = quote?['coins'] as Map?;
    if (needsPin ?? pin?['required'] == true) {
      final outcome = await runWithMpin(
        context,
        isSet: isSet ?? pin?['isSet'] != false,
        length: pin?['length'] as int? ?? 4,
        subtitle:
            'Pay ${tvsCoins(coins?['total'], coins?['currency'])} for your order',
        attempt: (p) => cubit.payWithTvs(pin: p),
      );
      if (!context.mounted || outcome == null) return;
      if (outcome.result != null) return _tvsPaid(context, cubit);
      return _tvsFailed(context, cubit, outcome.failure!);
    }
    try {
      await cubit.payWithTvs();
      if (context.mounted) _tvsPaid(context, cubit);
    } catch (e) {
      if (context.mounted) _tvsFailed(context, cubit, e);
    }
  }

  void _tvsPaid(BuildContext context, PaymentMethodCubit cubit) {
    AppSnackbar.showSuccess(context, 'Paid with TVS Coins');
    context.pushReplacement(AppRoutes.paymentSuccess, extra: cubit);
  }

  void _tvsFailed(BuildContext context, PaymentMethodCubit cubit, Object e) {
    if (e is TvsQrException) {
      switch (e.code) {
        // The PIN limit changed since the quote: ask for the MPIN now.
        case 'PIN_REQUIRED' || 'PIN_NOT_SET':
          _payWithTvs(
            context,
            cubit,
            needsPin: true,
            isSet: e.code == 'PIN_REQUIRED',
          );
          return;
        case 'QUOTE_CHANGED':
          AppSnackbar.showError(context, e.message);
          cubit.loadTvsQuote(); // shows the new price to confirm
          return;
      }
    }
    AppSnackbar.showError(
      context,
      e is TvsQrException
          ? e.message
          : 'The payment didn’t go through. You were not charged.',
    );
  }
}

// The TVS Wallet option's line: the price in coins (and the offer saved), the
// balance, or why it can't pay.
String _tvsSubtitle(Map<String, dynamic>? q) {
  if (q == null) return 'Checking your TVS Coins…';
  if (q['canPay'] != true) {
    return '${q['reason'] ?? 'Not available for this order'}';
  }
  final c = (q['coins'] as Map?) ?? const {};
  final cur = c['currency'];
  final saved = (num.tryParse('${c['discount']}') ?? 0) > 0
      ? ' (${tvsCoins(c['discount'], cur)} off)'
      : '';
  return '${tvsCoins(c['total'], cur)}$saved · '
      'Balance ${tvsCoins((q['wallet'] as Map?)?['spendable'], cur)}';
}

// One payment option: icon, name, a line about it, and a radio.
class _MethodRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MethodRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: selected
            ? colors.brandSoft.withValues(alpha: 0.5)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? colors.surface : colors.brandSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: colors.brand, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: checkoutText(
                          colors.textPrimary,
                          size: 15,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: checkoutText(colors.textSecondary, size: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: selected ? colors.brand : colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A coupon and a note for the seller: quiet links until tapped.
class _CouponAndNote extends StatefulWidget {
  const _CouponAndNote();

  @override
  State<_CouponAndNote> createState() => _CouponAndNoteState();
}

class _CouponAndNoteState extends State<_CouponAndNote> {
  late final _cubit = context.read<PaymentMethodCubit>();
  late final _coupon = TextEditingController(text: _cubit.state.couponCode);
  late final _note = TextEditingController(text: _cubit.state.notes);

  @override
  void dispose() {
    _coupon.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = ReviewPaymentMetrics.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        ReviewPaymentNoteSection(
          metrics: m,
          controller: _coupon,
          onChanged: (v) => _cubit.updateCouponCode(v.trim()),
          label: 'Apply coupon',
          hint: 'Coupon code',
          icon: Icons.local_offer_outlined,
          maxLength: 40,
          capitalization: TextCapitalization.characters,
        ),
        ReviewPaymentNoteSection(
          metrics: m,
          controller: _note,
          onChanged: (v) => _cubit.updateNotes(v.trim()),
          label: 'Add delivery notes',
          hint: 'e.g. Leave at the door',
          maxLength: 200,
        ),
      ],
    );
  }
}
