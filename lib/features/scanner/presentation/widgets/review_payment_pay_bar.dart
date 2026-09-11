import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import 'review_payment_metrics.dart';

// ── Pay bar ────────────────────────────────────────────────────────────────
class ReviewPaymentPayBar extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPay;

  const ReviewPaymentPayBar({
    super.key,
    required this.metrics,
    required this.isLoading,
    required this.isEnabled,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: m.payNoteSize + 4,
              color: colors.statusSuccess,
            ),
            SizedBox(width: m.gapXs),
            Flexible(
              child: Text(
                'Your payment details are secure with 256-bit encryption',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.payNoteSize,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: m.gapSm),

        AppButton(
          label: 'Proceed to Pay',
          suffixIcon: Icons.chevron_right_rounded,
          isLoading: isLoading,
          onPressed: isEnabled ? onPay : null,
          height: m.payHeight,
          fontSize: m.payFontSize,
        ),
      ],
    );
  }
}
