// // lib/features/orders/presentation/widgets/order_filter_tabs.dart
//
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
// import 'package:bingo_pay/core/theme/app_text_styles.dart';
//
// class OrderFilterTabs extends StatelessWidget {
//   final String activeFilter;
//   final ValueChanged<String> onFilterChanged;
//
//   const OrderFilterTabs({
//     super.key,
//     required this.activeFilter,
//     required this.onFilterChanged,
//   });
//
//   static const _filters = [
//     'All',
//     'Pending',
//     'Processing',
//     'Shipped',
//     'Delivered',
//     'Cancelled',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: _filters.map((filter) {
//           final isActive = filter == activeFilter;
//           return GestureDetector(
//             onTap: () => onFilterChanged(filter),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               margin: EdgeInsets.only(right: 2.w),
//               padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//               decoration: BoxDecoration(
//                 color: isActive ? ThemeColors.blue : ThemeColors.surface,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: isActive ? ThemeColors.blue : ThemeColors.line,
//                 ),
//               ),
//               child: Text(
//                 filter,
//                 style: AppTextStyles.labelMedium.copyWith(
//                   fontSize: 15.sp,
//                   fontWeight: FontWeight.bold,
//                   color: isActive ? ThemeColors.white : ThemeColors.inkMid,
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
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
    final c = context.c;
    final m = metrics;

    return Container(
      height: m.tabBarHeight,
      margin: EdgeInsets.symmetric(horizontal: m.pagePadding),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.tabRadius),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 0.3),
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: m.tabGap),
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
    final c = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 0.55),
        // CHANGED: IntrinsicWidth se Column ko finite width milti hai,
        // taaki underline row ki asli chaudai le sake
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
                        color: selected ? c.brand : c.textSecondary,
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
                        color: selected ? c.brand : c.surfaceAlt,
                        borderRadius: BorderRadius.circular(m.tabBadgeSize),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: m.tabBadgeFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: selected ? Colors.white : c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // CHANGED: width: double.infinity hataya — stretch handle karega
              Container(
                height: 2.5,
                color: selected ? c.brand : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
