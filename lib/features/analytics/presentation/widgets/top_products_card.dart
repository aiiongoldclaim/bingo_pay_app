import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_currency.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/vendor_analytics_model.dart';
import 'analytics_card.dart';
import 'analytics_chart_style.dart';
import 'analytics_value_bar.dart';

/// Best sellers for the period, ranked by revenue — each row carries a
/// proportional revenue bar scaled to the #1 product.
class TopProductsCard extends StatelessWidget {
  final List<TopProduct> products;
  final String periodLabel;

  const TopProductsCard({
    super.key,
    required this.products,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = NumberFormat.decimalPattern();
    final maxRevenue = products.fold(
      0.0,
      (max, p) => p.revenue > max ? p.revenue : max,
    );

    return AnalyticsCard(
      title: 'Top products',
      subtitle: 'Last ${periodLabel.toLowerCase()}',
      child: Column(
        children: [
          for (final (i, product) in products.indexed) ...[
            if (i > 0) Divider(height: AppDimensions.md, color: colors.border),
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${count.format(product.unitsSold)} units · '
                        '${count.format(product.orderLines)} orders',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnalyticsMeterBar(
                        fraction: maxRevenue > 0
                            ? product.revenue / maxRevenue
                            : 0,
                        color: AnalyticsChartStyle.lineColor(context),
                        height: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  AppCurrency.format(product.revenue),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
