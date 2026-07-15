import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/vendor_analytics_model.dart';
import 'analytics_card.dart';
import 'analytics_chart_style.dart';
import 'analytics_value_bar.dart';

/// Variant availability as a single stacked bar (in / low / out of stock)
/// with a labeled legend, followed by the stock counters as proportional bars.
class InventoryHealthCard extends StatelessWidget {
  final AnalyticsInventory inventory;

  const InventoryHealthCard({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = NumberFormat.decimalPattern();
    final segments = [
      (
        label: 'In stock',
        value: inventory.inStockVariants,
        color: colors.successFg,
      ),
      (
        label: 'Low stock',
        value: inventory.lowStockVariants,
        color: colors.warningFg,
      ),
      (
        label: 'Out of stock',
        value: inventory.outOfStockVariants,
        color: colors.errorFg,
      ),
    ];
    final total = segments.fold(0, (sum, s) => sum + s.value);

    return AnalyticsCard(
      title: 'Inventory health',
      subtitle: '${count.format(inventory.totalVariants)} variants',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    for (final (i, segment) in segments.indexed)
                      if (segment.value > 0) ...[
                        if (i > 0 &&
                            segments.take(i).any((s) => s.value > 0))
                          const SizedBox(width: 2),
                        Expanded(
                          flex: segment.value,
                          child: ColoredBox(color: segment.color),
                        ),
                      ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.sm + 4),
            Wrap(
              spacing: AppDimensions.md,
              runSpacing: 4,
              children: [
                for (final segment in segments)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: segment.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${segment.label} ${count.format(segment.value)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: AppDimensions.sm),
          ],
          ..._counterBars(context, count),
        ],
      ),
    );
  }

  List<Widget> _counterBars(BuildContext context, NumberFormat count) {
    final counters = [
      ('Stock on hand', inventory.stockOnHand),
      ('Reserved', inventory.reservedStock),
      ('Sold', inventory.soldStock),
      ('Returned', inventory.returnedStock),
      ('Damaged', inventory.damagedStock),
    ];
    final maxValue = counters.fold(0, (max, c) => c.$2 > max ? c.$2 : max);

    return [
      for (final (label, value) in counters)
        AnalyticsValueBar(
          label: label,
          value: count.format(value),
          fraction: maxValue > 0 ? value / maxValue : 0,
          color: AnalyticsChartStyle.lineColor(context),
          labelWidth: 104,
        ),
    ];
  }
}
