// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
// import 'package:bingo_pay/core/theme/app_text_styles.dart';
//
// class TransactionFilterTabs extends StatelessWidget {
//   final String activeFilter;
//   final ValueChanged<String> onFilterChanged;
//
//   const TransactionFilterTabs({
//     super.key,
//     required this.activeFilter,
//     required this.onFilterChanged,
//   });
//
//   static const _filters = ['All', 'Success', 'Pending', 'Failed'];
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
//                 color: isActive ? ThemeColors.primaryPurple : ThemeColors.surface,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: isActive ? ThemeColors.primaryPurple : ThemeColors.line,
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
import 'package:bingo_pay/features/transactions/presentation/widgets/transactions_metrics.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';


class TransactionFilterTabs extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const TransactionFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  static const _filters = ['All', 'Success', 'Pending', 'Failed'];

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = TransactionsMetrics.of(context);

    return SizedBox(
      height: m.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: m.gapSm),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isActive = filter == activeFilter;

          return Material(
            color: isActive ? colors.brand : colors.surface,
            borderRadius: BorderRadius.circular(m.chipRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: m.chipHPad),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(m.chipRadius),
                  border: Border.all(
                    color: isActive ? colors.brand : colors.border,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isActive ? colors.surface : colors.textSecondary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: m.chipFontSize,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}