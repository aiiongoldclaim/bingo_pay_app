import 'package:flutter/material.dart';

import '../../../../core/constants/app_currency.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/vendor_analytics_model.dart';
import 'analytics_card.dart';
import 'analytics_chart_style.dart';
import 'analytics_value_bar.dart';

/// Line-item breakdown from gross sales down to net earnings, plus payouts.
/// Each component gets a proportional bar (scaled to the largest line item);
/// deductions are drawn in the error hue.
class RevenueBreakdownCard extends StatelessWidget {
  final AnalyticsRevenue revenue;

  const RevenueBreakdownCard({super.key, required this.revenue});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = [
      ('Subtotal', revenue.subtotal),
      ('Discount', -revenue.discount),
      ('Tax', revenue.tax),
      ('Shipping', revenue.shipping),
      ('Commission', -revenue.commission),
    ];
    final maxAbs = items.fold(
      0.0,
      (max, item) => item.$2.abs() > max ? item.$2.abs() : max,
    );

    return AnalyticsCard(
      title: 'Revenue breakdown',
      child: Column(
        children: [
          for (final (label, value) in items)
            _row(context, label, value, maxAbs),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
            child: Divider(height: 1, color: colors.border),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Net earnings',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                AppCurrency.format(revenue.netEarnings),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.successFg,
                ),
              ),
            ],
          ),
          if (revenue.payouts.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.md),
            for (final payout in revenue.payouts)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm + 4,
                  vertical: AppDimensions.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_title(payout.status)} payouts'
                        ' (${payout.count})',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      AppCurrency.format(payout.netAmount),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    double value,
    double maxAbs,
  ) {
    final colors = context.colors;
    final negative = value < 0;
    final text = negative
        ? '-${AppCurrency.format(value.abs())}'
        : AppCurrency.format(value);

    return AnalyticsValueBar(
      label: label,
      value: text,
      fraction: maxAbs > 0 ? value.abs() / maxAbs : 0,
      color: negative
          ? colors.errorFg
          : AnalyticsChartStyle.lineColor(context),
      valueColor: negative ? colors.errorFg : null,
    );
  }

  String _title(String status) {
    final lower = status.toLowerCase().replaceAll('_', ' ');
    return lower.isEmpty ? status : lower[0].toUpperCase() + lower.substring(1);
  }
}
