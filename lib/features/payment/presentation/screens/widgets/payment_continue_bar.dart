import 'package:flutter/material.dart';

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
    final m = metrics;

    return AppButton(
      label: 'CONTINUE TO PAY  •  \$${total.toStringAsFixed(2)}',
      height: m.payHeight,
      fontSize: m.payFontSize,
      onPressed: isEnabled ? onPressed : null,
    );
  }
}
