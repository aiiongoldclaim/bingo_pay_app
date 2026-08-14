import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'order_details_metrics.dart';

class OdSectionTitle extends StatelessWidget {
  const OdSectionTitle({super.key, required this.metrics, required this.title});

  final OrderDetailMetrics metrics;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        // fontSize: metrics.sectionTitleSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: context.c.textPrimary,
      ),
    );
  }
}

/// Bordered surface — saare cards isi pe bante hain
class OdCard extends StatelessWidget {
  const OdCard({
    super.key,
    required this.metrics,
    required this.child,
    this.padded = true,
    this.color,
    this.borderColor,
  });

  final OrderDetailMetrics metrics;
  final Widget child;
  final bool padded;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      width: double.infinity,
      padding: padded ? EdgeInsets.all(m.cardPadding) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: borderColor ?? c.border),
      ),
      child: child,
    );
  }
}
