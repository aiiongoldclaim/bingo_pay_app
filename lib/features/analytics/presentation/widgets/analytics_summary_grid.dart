import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_currency.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../data/models/vendor_analytics_model.dart';

/// 2x2 KPI grid: net earnings, gross sales, new orders, avg order value.
/// Growth deltas compare against the previous period.
class AnalyticsSummaryGrid extends StatelessWidget {
  final AnalyticsSummary summary;

  const AnalyticsSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = NumberFormat.decimalPattern();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'Net earnings',
                value: AppCurrency.format(summary.netEarnings),
                deltaPct: summary.revenueGrowthPct,
                icon: Icons.account_balance_wallet_outlined,
                iconColor: colors.successFg,
                iconBackground: colors.successTint,
              ),
            ),
            const SizedBox(width: AppDimensions.sm + 4),
            Expanded(
              child: _SummaryTile(
                label: 'Gross sales',
                value: AppCurrency.format(summary.grossSales),
                icon: Icons.trending_up,
                iconColor: colors.infoFg,
                iconBackground: colors.infoTint,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm + 4),
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'New orders',
                value: count.format(summary.newOrders),
                deltaPct: summary.ordersGrowthPct,
                icon: Icons.shopping_bag_outlined,
                iconColor: colors.purpleFg,
                iconBackground: colors.purpleTint,
              ),
            ),
            const SizedBox(width: AppDimensions.sm + 4),
            Expanded(
              child: _SummaryTile(
                label: 'Avg order value',
                value: AppCurrency.format(summary.averageOrderValue),
                icon: Icons.receipt_long_outlined,
                iconColor: colors.warningFg,
                iconBackground: colors.warningTint,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final double? deltaPct;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const _SummaryTile({
    required this.label,
    required this.value,
    this.deltaPct,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final delta = deltaPct;
    final deltaUp = (delta ?? 0) >= 0;

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.sm + 4),
      radius: AppDimensions.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const Spacer(),
              if (delta != null) _DeltaBadge(pct: delta, up: deltaUp),
            ],
          ),
          const SizedBox(height: AppDimensions.sm + 4),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  final double pct;
  final bool up;

  const _DeltaBadge({required this.pct, required this.up});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = up ? colors.successFg : colors.errorFg;
    final bg = up ? colors.successTint : colors.errorTint;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 12,
            color: fg,
          ),
          const SizedBox(width: 2),
          Text(
            '${pct.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
