import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import 'payment_metrics.dart';

// ── Continue bar ───────────────────────────────────────────────────────────
class PaymentContinueBar extends StatelessWidget {
  final PaymentMetrics metrics;
  final bool isEnabled;
  final double total;
  final VoidCallback onPressed;

  const PaymentContinueBar({
    super.key,
    required this.metrics,
    required this.isEnabled,
    required this.total,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: 'CONTINUE TO PAY  •  \$${total.toStringAsFixed(2)}',
          height: m.payHeight,
          fontSize: m.payFontSize,
          onPressed: isEnabled ? onPressed : null,
        ),
        SizedBox(height: m.gapSm * 0.7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: m.payNoteSize + 3,
              color: colors.textMuted,
            ),
            SizedBox(width: m.gapXs),
            Flexible(
              child: Text(
                'Secure Payments. Easy Returns. 100% Authentic.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textMuted,
                  fontFamily: 'Inter',
                  fontSize: m.payNoteSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
