import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/stripe_status_response.dart';
import '../cubit/card_payment_cubit.dart';
import '../cubit/card_payment_state.dart';
import '../cubit/payment_cubit.dart';
import '../widgets/card_payment_status_view.dart';
import '../widgets/stripe_checkout_view.dart';

class CardPaymentScreen extends StatelessWidget {
  const CardPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return BlocConsumer<CardPaymentCubit, CardPaymentState>(
      listenWhen: (previous, current) => previous.phase != current.phase,
      listener: _onPhaseChanged,
      builder: (context, state) {
        final cubit = context.read<CardPaymentCubit>();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _onClose(context, state);
          },
          child: Scaffold(
            backgroundColor: colors.background,
            // A close button, not a back arrow: Stripe's page has its own.
            appBar: CustomAppBar(
              title: 'Card Payment',
              showBackButton: false,
              actionIcon1: Icons.close_rounded,
              onAction1: () => _onClose(context, state),
            ),
            body: SafeArea(
              child: state.phase == CardPaymentPhase.checkout
                  ? StripeCheckoutView(
                      checkoutUrl: state.checkoutUrl,
                      onReturn: (outcome) =>
                          outcome == StripeCheckoutReturn.success
                          ? cubit.onPaymentSubmitted()
                          : cubit.onCheckoutLeft(),
                    )
                  : CardPaymentStatusView(
                      state: state,
                      onCheckAgain: state.phase == CardPaymentPhase.backedOut
                          ? cubit.onCheckoutLeft
                          : cubit.checkAgain,
                      onBackToCheckout: () => context.pop(),
                      onGoHome: () => context.go(AppRoutes.home),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _onPhaseChanged(BuildContext context, CardPaymentState state) {
    if (state.phase == CardPaymentPhase.paid) {
      final paymentCubit = context.read<PaymentMethodCubit>();
      final order = state.payment?.order;

      paymentCubit.completeCardPayment(
        orderNumber: order?.orderNumber ?? '',
        orderUuid: order?.uuid ?? '',
      );
      context.pushReplacement(AppRoutes.paymentSuccess, extra: paymentCubit);
      return;
    }

    // Backed out and nothing was charged: straight back to the checkout,
    // with no screen in between.
    if (state.phase == CardPaymentPhase.closed &&
        state.payment?.status == StripePaymentStatus.cancelled &&
        !state.isRefunded) {
      AppSnackbar.showWarning(
        context,
        'Payment cancelled. Nothing was charged.',
      );
      context.pop();
    }
  }

  void _onClose(BuildContext context, CardPaymentState state) {
    switch (state.phase) {
      case CardPaymentPhase.checkout:
        context.read<CardPaymentCubit>().onCheckoutLeft();
      case CardPaymentPhase.backedOut:
        if (!state.isChecking) context.pop();
      case CardPaymentPhase.closed:
        context.pop();
      // The card may already have been charged, so there is no checkout to
      // go back to — the order turns up in My Orders once it is confirmed.
      case CardPaymentPhase.confirming:
      case CardPaymentPhase.reconciling:
        context.go(AppRoutes.home);
      case CardPaymentPhase.paid:
        break;
    }
  }
}
