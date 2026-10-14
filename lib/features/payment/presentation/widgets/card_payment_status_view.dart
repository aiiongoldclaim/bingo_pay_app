import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/price_formatter.dart';
import '../../data/models/stripe_status_response.dart';
import '../cubit/card_payment_state.dart';
import 'review_pay_metrics.dart';

// What a crypto payment is doing, in words a customer can act on. `confirmed`
// is deliberately not phrased as done: only the server calls a payment paid.
const _cryptoProgress = {
  'confirming': 'Your payment is on the network and is being confirmed.',
  'confirmed':
      'The network has confirmed your payment. Finalising it now — this is '
      'the last step.',
  'sending': 'Your payment is being settled.',
  'partially_paid':
      'We received part of the amount. Our team will be in touch — please do '
      'not send another payment.',
};

// What the customer sees once Stripe's page is out of the way: the payment
// being confirmed, or how it ended.
class CardPaymentStatusView extends StatelessWidget {
  final CardPaymentState state;
  final VoidCallback onCheckAgain;
  // Crypto only: reopen the invoice page.
  final VoidCallback onResumeCheckout;
  final VoidCallback onBackToCheckout;
  final VoidCallback onGoHome;

  const CardPaymentStatusView({
    super.key,
    required this.state,
    required this.onCheckAgain,
    required this.onResumeCheckout,
    required this.onBackToCheckout,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = ReviewPayMetrics.of(context);
    final payment = state.payment;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: m.isTablet ? 520 : double.infinity,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: m.pageHPad * 1.5,
            vertical: m.gapLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._content(context, m),

              if (payment != null) ...[
                SizedBox(height: m.gapLg),
                Divider(color: colors.border, height: 1),
                SizedBox(height: m.gapMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontSize: m.rowLabelSize,
                      ),
                    ),
                    Text(
                      '\$${formatGroupedAmount(payment.amount)} ${payment.currency}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontSize: m.rowValueSize,
                      ),
                    ),
                  ],
                ),
              ],

              if (state.errorMessage != null) ...[
                SizedBox(height: m.gapMd),
                Text(
                  state.phase == CardPaymentPhase.confirming
                      ? '${state.errorMessage} Your payment is unaffected — '
                            'we will keep trying.'
                      : state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.statusWarning,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, ReviewPayMetrics m) {
    final colors = context.c;

    switch (state.phase) {
      case CardPaymentPhase.checkout:
        return const [];

      case CardPaymentPhase.confirming:
        return [
          state.gaveUp
              ? _StatusIcon(
                  icon: Icons.schedule_rounded,
                  color: colors.statusWarning,
                )
              : const _StatusSpinner(),
          _title(
            context,
            m,
            state.isAwaitingCrypto
                ? 'Waiting for your payment'
                : 'Confirming your payment',
          ),
          _message(
            context,
            m,
            !state.isCrypto
                ? 'This usually takes a few seconds. Your order is placed the '
                      'moment the payment is confirmed, and will appear in My '
                      'Orders.'
                : state.isAwaitingCrypto
                ? 'We have not seen your payment yet. It can take a few '
                      'minutes to show up after you send it. If you have '
                      'already sent it, stay here — do not pay again.'
                : _cryptoProgress[state.payment?.gatewayStatus] ??
                      'Your order is placed the moment the payment is '
                          'confirmed, and will appear in My Orders.',
          ),
          if (state.gaveUp)
            _message(
              context,
              m,
              'We have stopped checking automatically. Your payment is still '
              'being watched on our side.',
            ),
          if (state.isAwaitingCrypto) ...[
            SizedBox(height: m.gapLg),
            _button(
              m,
              label: 'Back to payment page',
              onPressed: onResumeCheckout,
            ),
            SizedBox(height: m.gapSm),
            _button(
              m,
              label: 'Pay another way',
              onPressed: onBackToCheckout,
              outlined: true,
            ),
          ] else if (state.gaveUp) ...[
            SizedBox(height: m.gapLg),
            _button(m, label: 'Check again', onPressed: onCheckAgain),
            SizedBox(height: m.gapSm),
            _button(m, label: 'Back to home', onPressed: onGoHome, outlined: true),
          ],
        ];

      case CardPaymentPhase.backedOut:
        if (state.isChecking) {
          return [
            const _StatusSpinner(),
            _title(context, m, 'Cancelling your payment'),
          ];
        }
        // No answer from the server, so the card may or may not be charged.
        return [
          _StatusIcon(
            icon: Icons.wifi_off_rounded,
            color: colors.statusWarning,
          ),
          _title(context, m, 'We could not check your payment'),
          _message(
            context,
            m,
            'We could not reach the server, so we do not know yet whether '
            'your card was charged. Check your connection and try again.',
          ),
          SizedBox(height: m.gapLg),
          _button(m, label: 'Check again', onPressed: onCheckAgain),
        ];

      case CardPaymentPhase.paid:
        return [
          _StatusIcon(
            icon: Icons.check_circle_outline_rounded,
            color: colors.statusSuccess,
          ),
          _title(context, m, 'Payment received'),
          _message(context, m, 'Your order is confirmed.'),
        ];

      case CardPaymentPhase.closed:
        final status = state.payment?.status;
        return [
          _StatusIcon(icon: Icons.cancel_outlined, color: colors.error),
          _title(
            context,
            m,
            state.isRefunded
                ? 'Payment refunded'
                : status == StripePaymentStatus.expired
                ? 'This payment window closed'
                : status == StripePaymentStatus.cancelled
                ? 'Payment cancelled'
                : 'Payment not completed',
          ),
          _message(
            context,
            m,
            state.isRefunded
                ? 'Your card was charged, but an item sold out before your '
                      'order could be placed, so the full amount has been '
                      'refunded. It can take 5–10 days to appear on your '
                      'statement.'
                : state.isCrypto
                ? 'No order was placed. If you sent a payment for it, '
                      'contact support and we will sort it out. Your items '
                      'are still available to buy.'
                : 'No order was placed and nothing has been charged. Your '
                      'items are still available to buy.',
          ),
          SizedBox(height: m.gapLg),
          _button(m, label: 'Back to checkout', onPressed: onBackToCheckout),
        ];

      case CardPaymentPhase.reconciling:
        return [
          _StatusIcon(
            icon: Icons.warning_amber_rounded,
            color: colors.statusWarning,
          ),
          _title(context, m, 'Your payment went through'),
          _message(
            context,
            m,
            'We are reviewing it before confirming your order. Our team has '
            'been notified — ${state.isCrypto ? 'please do not send another '
                      'payment' : 'you will not be charged twice'}.',
          ),
          SizedBox(height: m.gapLg),
          _button(m, label: 'Back to home', onPressed: onGoHome),
        ];
    }
  }

  Widget _title(BuildContext context, ReviewPayMetrics m, String text) {
    return Padding(
      padding: EdgeInsets.only(top: m.gapMd),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.titleLarge.copyWith(
          color: context.c.textPrimary,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: m.pageTitleSize,
        ),
      ),
    );
  }

  Widget _message(BuildContext context, ReviewPayMetrics m, String text) {
    return Padding(
      padding: EdgeInsets.only(top: m.gapSm),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(
          color: context.c.textSecondary,
          fontFamily: 'Inter',
          fontSize: m.rowLabelSize,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _button(
    ReviewPayMetrics m, {
    required String label,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: outlined ? AppButtonVariant.outlined : AppButtonVariant.primary,
      height: m.payHeight,
      fontSize: m.payFontSize,
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _StatusIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 32, color: color),
      ),
    );
  }
}

class _StatusSpinner extends StatelessWidget {
  const _StatusSpinner();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: context.c.brand,
        ),
      ),
    );
  }
}
