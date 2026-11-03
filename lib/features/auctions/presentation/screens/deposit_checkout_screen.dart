import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../payment/data/models/stripe_intent_response.dart';
import '../../../payment/data/models/stripe_status_response.dart';
import '../../../payment/presentation/cubit/card_payment_cubit.dart';
import '../../../payment/presentation/cubit/card_payment_state.dart';
import '../../../payment/presentation/widgets/stripe_checkout_view.dart';
import '../../../tvs_wallet/presentation/widgets/tvs_ui.dart';

// A lot's bidding fee on Stripe's checkout page or a NOWPayments invoice,
// inside the app. The gateway sends the bidder back to
// /auctions/:uuid?deposit=…&from=success|cancelled; that navigation is caught
// by StripeCheckoutView and the payment is then polled. The gateway's webhook
// records the deposit — the app never does. Pops true once it is PAID.
class DepositCheckoutScreen extends StatelessWidget {
  const DepositCheckoutScreen({super.key});

  static Future<bool> open(
    BuildContext context,
    StripeIntentResponse intent, {
    required bool isCrypto,
  }) async {
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => CardPaymentCubit(intent: intent, isCrypto: isCrypto),
          child: const DepositCheckoutScreen(),
        ),
      ),
    );
    return paid == true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardPaymentCubit, CardPaymentState>(
      listenWhen: (previous, current) => previous.phase != current.phase,
      listener: (context, state) {
        if (state.phase == CardPaymentPhase.paid) {
          Navigator.pop(context, true);
          return;
        }
        // Backed out of the card page and nothing was charged: straight back.
        if (!state.isCrypto &&
            state.phase == CardPaymentPhase.closed &&
            state.payment?.status == StripePaymentStatus.cancelled &&
            !state.isRefunded) {
          AppSnackbar.showWarning(
            context,
            'Payment cancelled. Nothing was charged.',
          );
          Navigator.pop(context, false);
        }
      },
      builder: (context, state) {
        final cubit = context.read<CardPaymentCubit>();
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _close(context, state);
          },
          child: Scaffold(
            backgroundColor: context.colors.background,
            appBar: CustomAppBar(
              title: state.isCrypto ? 'Crypto Payment' : 'Card Payment',
              showBackButton: false,
              actionIcon1: Icons.close_rounded,
              onAction1: () => _close(context, state),
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
                  : _Status(state: state, cubit: cubit),
            ),
          ),
        );
      },
    );
  }

  void _close(BuildContext context, CardPaymentState state) {
    switch (state.phase) {
      case CardPaymentPhase.checkout:
        context.read<CardPaymentCubit>().onCheckoutLeft();
      case CardPaymentPhase.backedOut:
        if (!state.isChecking) Navigator.pop(context, false);
      // A payment still being confirmed is recorded by the webhook either
      // way; the lot shows the fee as paid once it is.
      case CardPaymentPhase.confirming ||
          CardPaymentPhase.closed ||
          CardPaymentPhase.reconciling:
        Navigator.pop(context, false);
      case CardPaymentPhase.paid:
        break;
    }
  }
}

class _Status extends StatelessWidget {
  final CardPaymentState state;
  final CardPaymentCubit cubit;

  const _Status({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final back = AppButton(
      label: 'Back',
      variant: AppButtonVariant.outlined,
      onPressed: () => Navigator.pop(context, false),
    );

    final (title, message, actions) = switch (state.phase) {
      CardPaymentPhase.closed => (
        state.isRefunded ? 'Payment refunded' : 'Payment not completed',
        state.isRefunded
            ? 'The token money was refunded. It can take 5–10 days to '
                  'appear on your statement.'
            : 'The token money was not paid. You can try again or pay '
                  'another way.',
        [back],
      ),
      CardPaymentPhase.reconciling => (
        'Your payment is being reviewed',
        'We will confirm it shortly — please do not pay again.',
        [back],
      ),
      CardPaymentPhase.backedOut when !state.isChecking => (
        'We could not check your payment',
        'Check your connection and try again.',
        [
          AppButton(label: 'Check again', onPressed: cubit.onCheckoutLeft),
          back,
        ],
      ),
      _ => (
        state.isAwaitingCrypto
            ? 'Waiting for your payment'
            : 'Confirming your payment',
        state.gaveUp
            ? 'We have stopped checking automatically. If you paid, the lot '
                  'shows it shortly.'
            : 'Stay here — your bid goes in as soon as the token money is '
                  'received.',
        [
          if (state.isAwaitingCrypto)
            AppButton(
              label: 'Back to payment page',
              onPressed: cubit.resumeCheckout,
            ),
          if (state.gaveUp)
            AppButton(label: 'Check again', onPressed: cubit.checkAgain),
          back,
        ],
      ),
    };
    final waiting =
        state.phase == CardPaymentPhase.confirming ||
        (state.phase == CardPaymentPhase.backedOut && state.isChecking);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        if (waiting && !state.gaveUp)
          Center(child: CircularProgressIndicator(color: colors.brand))
        else
          Icon(
            Icons.info_outline_rounded,
            size: 40,
            color: colors.textMuted,
          ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: tvsText(colors.textPrimary, size: 18, weight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: tvsText(colors.textSecondary, size: 14),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: tvsText(colors.error, size: 13),
          ),
        ],
        const SizedBox(height: 24),
        for (final a in actions) ...[a, const SizedBox(height: 12)],
      ],
    );
  }
}
