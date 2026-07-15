import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_currency.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/vendor_analytics_model.dart';
import 'analytics_card.dart';
import 'analytics_chart_style.dart';

enum _TrendMetric { revenue, orders }

/// Timeseries line chart. Revenue and orders live on different scales, so
/// they are never plotted together — a toggle swaps the single series.
class AnalyticsTrendChart extends StatefulWidget {
  final List<TimeseriesPoint> points;
  final String periodLabel;

  const AnalyticsTrendChart({
    super.key,
    required this.points,
    required this.periodLabel,
  });

  @override
  State<AnalyticsTrendChart> createState() => _AnalyticsTrendChartState();
}

class _AnalyticsTrendChartState extends State<AnalyticsTrendChart> {
  _TrendMetric _metric = _TrendMetric.revenue;

  @override
  Widget build(BuildContext context) {
    final isRevenue = _metric == _TrendMetric.revenue;

    return AnalyticsCard(
      title: isRevenue ? 'Revenue trend' : 'Orders trend',
      subtitle: 'Last ${widget.periodLabel.toLowerCase()}',
      trailing: _MetricToggle(
        metric: _metric,
        onChanged: (m) => setState(() => _metric = m),
      ),
      child: widget.points.length < 2
          ? _EmptyChart(message: 'Not enough data for this period')
          : _TrendLine(points: widget.points, isRevenue: isRevenue),
    );
  }
}

class _TrendLine extends StatelessWidget {
  final List<TimeseriesPoint> points;
  final bool isRevenue;

  const _TrendLine({required this.points, required this.isRevenue});

  @override
  Widget build(BuildContext context) {
    final lineColor = AnalyticsChartStyle.lineColor(context);
    final dateFormat = DateFormat('d MMM');
    final values = [
      for (final p in points) isRevenue ? p.revenue : p.orders.toDouble(),
    ];
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;
    // At most ~4 bottom labels regardless of how many points came back.
    final labelInterval = (points.length / 4).ceil().toDouble();

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AnalyticsChartStyle.gridColor(context),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: maxY / 3,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    _compact(value, currency: isRevenue),
                    style: TextStyle(
                      fontSize: 10,
                      color: context.colors.textMuted,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: labelInterval,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 ||
                      index >= points.length ||
                      (value - index).abs() > 0.01) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dateFormat.format(points[index].date),
                      style: TextStyle(
                        fontSize: 10,
                        color: context.colors.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.primary,
              getTooltipItems: (spots) => spots.map((spot) {
                final point = points[spot.x.round()];
                final valueText = isRevenue
                    ? AppCurrency.format(point.revenue)
                    : '${point.orders} orders';
                return LineTooltipItem(
                  '${dateFormat.format(point.date)}\n$valueText',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: lineColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _compact(double value, {required bool currency}) {
    final formatted = NumberFormat.compact().format(value);
    return currency ? '${AppCurrency.symbol}$formatted' : formatted;
  }
}

class _MetricToggle extends StatelessWidget {
  final _TrendMetric metric;
  final ValueChanged<_TrendMetric> onChanged;

  const _MetricToggle({required this.metric, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final m in _TrendMetric.values)
            GestureDetector(
              onTap: () => onChanged(m),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: m == metric
                      ? Theme.of(context).cardColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusCircular,
                  ),
                  boxShadow: m == metric
                      ? [BoxShadow(color: colors.shadow, blurRadius: 4)]
                      : null,
                ),
                child: Text(
                  m == _TrendMetric.revenue ? 'Revenue' : 'Orders',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: m == metric
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: m == metric
                        ? colors.textPrimary
                        : colors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 13, color: context.colors.textMuted),
        ),
      ),
    );
  }
}
