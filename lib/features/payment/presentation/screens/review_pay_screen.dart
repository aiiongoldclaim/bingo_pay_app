import 'package:bingo_pay/features/payment/presentation/screens/widgets/review_pay_metrics.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/review_pay_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'widgets/payment_method_picker.dart';
import 'widgets/review_address_card.dart';
import 'widgets/review_body.dart';
import 'widgets/review_order_summary_card.dart';
import 'widgets/review_pay_bar.dart';
import 'widgets/review_paying_with_card.dart';
import 'widgets/review_top_bar.dart';

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

          final wallet = ReviewPayingWithCard(
            metrics: m,
            methodName: state.methodDisplayName,
            bigoldBalance: state.formattedBigoldBalance,
            selectedMethod: state.selectedMethod ?? PaymentMethod.wallet,
            onChangeTap: () => showPaymentMethodPicker(
              context,
              state.selectedMethod ?? PaymentMethod.wallet,
            ),
          );

          final summary = ReviewOrderSummaryCard(
            metrics: m,
            productName: state.isCartFlow ? '' : state.productName,
            cartItems: state.cartItems,
            itemTotal: state.itemTotal > 0
                ? '\$${state.itemTotal.toStringAsFixed(0)}'
                : 'N/A',
            savings: state.savings > 0
                ? '- \$${state.savings.toStringAsFixed(0)}'
                : '\$0',
            delivery: state.deliveryCharge == 0
                ? '\$0'
                : '\$${state.deliveryCharge}',
            tax: '\$${state.taxes.toStringAsFixed(0)}',
            total: state.formattedTotal,
          );

          final offers = ReviewOffersCard(
            metrics: m,
            offers: const [
              ReviewOffer(
                title: '10% Instant Discount on Bank Cards',
                subtitle: 'Min. spend \$50 | T&C',
              ),
              ReviewOffer(
                title: 'Extra 5% off on Wallet',
                subtitle: 'Max. discount \$10',
              ),
            ],
            onViewAll: () {},
          );
          final secure = ReviewInfoStrip(
            metrics: m,
            icon: Icons.verified_user_outlined,
            title: '100% Secure Payment',
            subtitle: 'PCI DSS encrypted & safe checkout',
          );

          final payBar = ReviewPayBar(
            metrics: m,
            amount: state.formattedTotal,
            label: state.selectedMethod == PaymentMethod.cashOnDelivery
                ? 'PLACE ORDER'
                : 'PAY NOW',
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

  // ── Payment logic — unchanged ─────────────────────────────────────────
  Future<void> _onPay(BuildContext context) async {
    final cubit = context.read<PaymentMethodCubit>();
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
