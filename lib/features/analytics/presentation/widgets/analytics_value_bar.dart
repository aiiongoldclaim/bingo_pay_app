import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Proportional horizontal bar on a subtle track — the fill width encodes
/// the value relative to the card's largest value.
class AnalyticsMeterBar extends StatelessWidget {
  final double fraction;
  final Color color;
  final double height;

  const AnalyticsMeterBar({
    super.key,
    required this.fraction,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: radius,
      ),
      child: fraction <= 0
          ? null
          : LayoutBuilder(
              builder: (context, constraints) {
                // Floor so tiny non-zero values stay visible.
                final width = (constraints.maxWidth * fraction.clamp(0.0, 1.0))
                    .clamp(height, constraints.maxWidth)
                    .toDouble();
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(height / 2),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Single metric row: label · proportional bar · value. Text stays in text
/// tokens; only the bar carries the series color.
class AnalyticsValueBar extends StatelessWidget {
  final String label;
  final String value;
  final double fraction;
  final Color color;
  final Color? valueColor;
  final double labelWidth;

  const AnalyticsValueBar({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
    this.valueColor,
    this.labelWidth = 96,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: AnalyticsMeterBar(fraction: fraction, color: color)),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
