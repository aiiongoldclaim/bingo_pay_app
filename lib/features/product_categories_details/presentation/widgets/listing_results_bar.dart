import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../product_categories_cubit/product_categories_state.dart';

/// "1,240 results" row with Grid view / List view toggle button.
class ListingResultsBar extends StatelessWidget {
  final int count;
  final ViewMode viewMode;
  final VoidCallback onToggleView;

  const ListingResultsBar({
    super.key,
    required this.count,
    required this.viewMode,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final isGrid = viewMode == ViewMode.grid;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Text(
            '${_formatCount(count)} results',
            style: AppTextStyles.bodyMedium.copyWith(
              color: ThemeColors.inkMid,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onToggleView,
            child: Row(
              children: [
                Icon(
                  isGrid ? Icons.grid_view_rounded : Icons.view_list_rounded,
                  color: ThemeColors.blue,
                  size: 16.sp,
                ),
                SizedBox(width: 1.w),
                Text(
                  isGrid ? 'Grid view' : 'List view',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: ThemeColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) {
      final s = n.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return '$n';
  }
}
