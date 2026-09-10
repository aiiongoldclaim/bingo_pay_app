import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_button.dart';
import 'review_pay_metrics.dart';

// ── Pay bar ────────────────────────────────────────────────────────────────
class ReviewPayBar extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final String amount;
  final String label;
  final bool isLoading;
  final VoidCallback onPay;

  const ReviewPayBar({
    super.key,
    required this.metrics,
    required this.amount,
    required this.label,
    required this.isLoading,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return AppButton(
      label: '$label  $amount',
      prefixIcon: Icons.lock_outline_rounded,
      isLoading: isLoading,
      onPressed: isLoading ? null : onPay,
      height: m.payHeight,
      fontSize: m.payFontSize,
    );
  }
}
