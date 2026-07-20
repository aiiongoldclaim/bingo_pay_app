import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_currency.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/vendor_analytics_model.dart';
import 'analytics_card.dart';
import 'analytics_chart_style.dart';

/// Compact list of the latest orders with status pill and amount.
class AnalyticsRecentOrdersCard extends StatelessWidget {
  final List<AnalyticsRecentOrder> orders;
  final VoidCallback? onSeeAllTap;

  const AnalyticsRecentOrdersCard({
    super.key,
    required this.orders,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('d MMM, h:mm a');

    return AnalyticsCard(
      title: 'Recent orders',
      trailing: onSeeAllTap == null
          ? null
          : GestureDetector(
              onTap: onSeeAllTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See all',
                    style: TextStyle(fontSize: 13, color: colors.infoFg),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: colors.infoFg),
                ],
              ),
            ),
      child: Column(
        children: [
          for (final (i, order) in orders.indexed) ...[
            if (i > 0) Divider(height: AppDimensions.md, color: colors.border),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (order.createdAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          dateFormat.format(order.createdAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusPill(status: order.status),
                const SizedBox(width: AppDimensions.sm + 4),
                Text(
                  AppCurrency.format(order.amount),
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

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AnalyticsChartStyle.statusColor(context, status);
    final lower = status.toLowerCase().replaceAll('_', ' ');
    final label = lower.isEmpty
        ? status
        : lower[0].toUpperCase() + lower.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
