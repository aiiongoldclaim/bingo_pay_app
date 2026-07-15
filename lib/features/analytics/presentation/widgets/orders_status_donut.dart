import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/vendor_analytics_model.dart';
import 'analytics_card.dart';
import 'analytics_chart_style.dart';

/// Part-to-whole donut of orders by status. Identity never rides on color
/// alone — the legend carries label + count + share for every slice.
class OrdersStatusDonut extends StatelessWidget {
  final AnalyticsOrders orders;
  final String periodLabel;

  const OrdersStatusDonut({
    super.key,
    required this.orders,
    required this.periodLabel,
  });

  List<MapEntry<String, int>> get _entries {
    final byStatus = Map.of(orders.byStatus)
      ..removeWhere((_, count) => count <= 0);
    final ordered = <MapEntry<String, int>>[
      for (final status in AnalyticsChartStyle.statusOrder)
        if (byStatus.containsKey(status))
          MapEntry(status, byStatus.remove(status)!),
      ...byStatus.entries,
    ];
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final total = entries.fold(0, (sum, e) => sum + e.value);

    return AnalyticsCard(
      title: 'Orders by status',
      subtitle: 'Last ${periodLabel.toLowerCase()}',
      child: total == 0
          ? SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'No orders in this period',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textMuted,
                  ),
                ),
              ),
            )
          : Row(
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 44,
                          startDegreeOffset: -90,
                          sections: [
                            for (final entry in entries)
                              PieChartSectionData(
                                value: entry.value.toDouble(),
                                color: AnalyticsChartStyle.statusColor(
                                  context,
                                  entry.key,
                                ),
                                radius: 20,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            NumberFormat.decimalPattern().format(total),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'orders',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      for (final entry in entries)
                        _LegendRow(
                          color: AnalyticsChartStyle.statusColor(
                            context,
                            entry.key,
                          ),
                          label: _title(entry.key),
                          count: entry.value,
                          pct: entry.value / total * 100,
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _title(String status) {
    final lower = status.toLowerCase().replaceAll('_', ' ');
    return lower[0].toUpperCase() + lower.substring(1);
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final double pct;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Text(
            '${pct.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
