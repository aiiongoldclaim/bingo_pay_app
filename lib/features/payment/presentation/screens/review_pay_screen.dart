import 'package:bingo_pay/features/payment/presentation/widgets/review_pay_metrics.dart';
import 'package:bingo_pay/features/payment/presentation/widgets/review_pay_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/price_formatter.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/payment_method_option.dart';
import '../widgets/review_address_card.dart';
import '../widgets/review_body.dart';
import '../widgets/review_order_summary_card.dart';
import '../widgets/review_pay_bar.dart';
import '../widgets/review_top_bar.dart';
import 'payment_flow_args.dart';

class ReviewPayScreen extends StatelessWidget {
  final bool isCart;
  const ReviewPayScreen({super.key, required this.isCart});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colors.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: colors.isDark ? Brightness.dark : Brightness.light,
      ),
      child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
        builder: (context, state) {
          final m = ReviewPayMetrics.of(context);

          // ── Sections ────────────────────────────────────────────────
          final address = state.deliveryName.isEmpty
              ? null
              : ReviewAddressCard(metrics: m, state: state);

          final selected = state.selectedMethod ?? PaymentMethod.wallet;
          final wallet = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReviewSectionLabel(metrics: m, label: 'Payment Method'),
              for (final (method, icon, title, subtitle) in [
                (
                  PaymentMethod.wallet,
                  Icons.account_balance_wallet_outlined,
                  'Bingold Wallet',
                  'Balance: ${state.formattedBigoldBalance}',
                ),
                if (state.cardAvailable)
                  (
                    PaymentMethod.card,
                    Icons.credit_card_outlined,
                    'Credit / Debit Card',
                    "Pay on Stripe's secure page",
                  ),
                if (state.cryptoAvailable)
                  (
                    PaymentMethod.crypto,
                    Icons.currency_bitcoin,
                    'Pay with Crypto',
                    'BTC, ETH, USDT and more — priced in USD',
                  ),
                (
                  PaymentMethod.cashOnDelivery,
                  Icons.payments_outlined,
                  'Cash on Delivery',
                  'Pay with cash when your order arrives',
                ),
              ]) ...[
                SizedBox(height: m.gapSm),
                PaymentMethodCard(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  isSelected: selected == method,
                  onTap: () => context
                      .read<PaymentMethodCubit>()
                      .selectPaymentMethod(method),
                ),
              ],
            ],
          );

          final summary = ReviewOrderSummaryCard(
            metrics: m,
            productName: state.isCartFlow ? '' : state.productName,
            cartItems: state.cartItems,
            itemTotal: state.itemTotal > 0
                ? '\$${formatExactAmount(state.itemTotal)}'
                : 'N/A',
            savings: state.savings > 0
                ? '- \$${formatExactAmount(state.savings)}'
                : '\$0',
            // Tax, delivery and the total are the server's figures; until it
            // has answered there is nothing honest to put here.
            delivery: !state.isQuoted
                ? 'At payment'
                : state.deliveryCharge == 0
                ? '\$0'
                : '\$${formatExactAmount(state.deliveryCharge)}',
            tax: state.isQuoted
                ? '\$${formatExactAmount(state.taxes)}'
                : 'At payment',
            total: state.isQuoted ? state.formattedTotal : 'At payment',
          );

          // final offers = ReviewOffersCard(
          //   metrics: m,
          //   offers: const [
          //     ReviewOffer(
          //       title: '10% Instant Discount on Bank Cards',
          //       subtitle: 'Min. spend \$50 | T&C',
          //     ),
          //     ReviewOffer(
          //       title: 'Extra 5% off on Wallet',
          //       subtitle: 'Max. discount \$10',
          //     ),
          //   ],
          //   onViewAll: () {},
          // );
          final offers = const SizedBox.shrink();
          final secure = ReviewInfoStrip(
            metrics: m,
            icon: Icons.verified_user_outlined,
            title: '100% Secure Payment',
            subtitle: 'PCI DSS encrypted & safe checkout',
          );

          final payBar = ReviewPayBar(
            metrics: m,
            amount: state.isQuoted ? state.formattedTotal : '',
            label: switch (state.selectedMethod) {
              PaymentMethod.cashOnDelivery => 'PLACE ORDER',
              PaymentMethod.card => 'CONTINUE TO CARD PAYMENT',
              PaymentMethod.crypto => 'CONTINUE TO CRYPTO PAYMENT',
              _ => 'PAY NOW',
            },
            isLoading: state.isProcessing,
            onPay: () => _onPay(context),
          );

          return Scaffold(
            backgroundColor: colors.background,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  ReviewTopBar(metrics: m, cartCount: state.cartItems.length),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: m.maxContentWidth,
                        ),
                        child: m.isLandscape
                            ? ReviewLandscapeBody(
                                metrics: m,
                                state: state,
                                address: address,
                                wallet: wallet,
                                summary: summary,
                                secure: secure,
                                offers: offers,
                                payBar: payBar,
                              )
                            : ReviewPortraitBody(
                                metrics: m,
                                state: state,
                                address: address,
                                wallet: wallet,
                                summary: summary,
                                secure: secure,
                                offers: offers,
                              ),
                      ),
                    ),
                  ),

                  if (!m.isLandscape)
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        m.pageHPad,
                        m.gapSm,
                        m.pageHPad,
                        m.gapSm * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.background,
                        border: Border(
                          top: BorderSide(color: colors.border, width: 1),
                        ),
                      ),
                      child: SafeArea(top: false, child: payBar),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Payment logic ─────────────────────────────────────────────────────
  Future<void> _onPay(BuildContext context) async {
    final cubit = context.read<PaymentMethodCubit>();

    // Card payments finish on Stripe's page, not here: the card screen takes
    // over and moves on to the success screen once the server reports PAID.
    // Crypto payments do the same on NOWPayments' page.
    final method = cubit.state.selectedMethod;
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
}
