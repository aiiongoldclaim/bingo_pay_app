import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isActive = filter == activeFilter;
          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isActive ? ThemeColors.blue : ThemeColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? ThemeColors.blue : ThemeColors.line,
                ),
              ),
              child: Text(
                filter,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isActive ? ThemeColors.white : ThemeColors.inkMid,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
