import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';

// ── Section label ──────────────────────────────────────────────────────────
class ReviewPaymentSectionLabel extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final String label;

  const ReviewPaymentSectionLabel({
    super.key,
    required this.metrics,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        color: colors.textSecondary,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: m.sectionLabelSize,
        letterSpacing: 0.6,
      ),
    );
  }
}
