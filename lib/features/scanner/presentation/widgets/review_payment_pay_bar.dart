import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import 'review_payment_metrics.dart';

// ── Pay bar ────────────────────────────────────────────────────────────────
class ReviewPaymentPayBar extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final String label;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPay;

  const ReviewPaymentPayBar({
    super.key,
    required this.metrics,
    required this.label,
    required this.isLoading,
    required this.isEnabled,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      isLoading: isLoading,
      onPressed: isEnabled ? onPay : null,
      height: metrics.payHeight,
      fontSize: metrics.payFontSize,
    );
  }
}
