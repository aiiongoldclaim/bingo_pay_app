import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'orders_metrics.dart';

class OrderFilterTabs extends StatelessWidget {
  const OrderFilterTabs({
    super.key,
    required this.metrics,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.counts,
    this.filters = defaultFilters,
  });

  final OrdersMetrics metrics;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  /// filter label → order count
  final Map<String, int> counts;
  final List<String> filters;

  static const List<String> defaultFilters = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      height: m.tabBarHeight,
      margin: EdgeInsets.symmetric(horizontal: m.pagePadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.tabRadius),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 0.3),
        itemCount: filters.length,
        separatorBuilder: (_, _) => SizedBox(width: m.tabGap),
        itemBuilder: (context, i) {
          final filter = filters[i];
          return _FilterTab(
            metrics: m,
            label: filter,
            count: counts[filter] ?? 0,
            selected: filter == activeFilter,
            onTap: () => onFilterChanged(filter),
          );
        },
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.metrics,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final OrdersMetrics metrics;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 0.55),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: m.tabFontSize,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected ? colors.brand : colors.textSecondary,
                      ),
                    ),
                    SizedBox(width: m.pagePadding * 0.35),
                    Container(
                      constraints: BoxConstraints(minWidth: m.tabBadgeSize),
                      height: m.tabBadgeSize,
                      padding: EdgeInsets.symmetric(
                        horizontal: m.pagePadding * 0.3,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? colors.brand : colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(m.tabBadgeSize),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: m.tabBadgeFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: selected ? Colors.white : colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 2.5,
                color: selected ? colors.brand : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
