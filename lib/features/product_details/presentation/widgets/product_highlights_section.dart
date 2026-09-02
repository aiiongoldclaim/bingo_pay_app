import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Product highlights checklist.
class ProductHighlightsSection extends StatelessWidget {
  final List<String> highlights;

  const ProductHighlightsSection({super.key, required this.highlights});

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      // margin: EdgeInsets.only(top: 1.h),
      color: ThemeColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Highlights',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: ThemeColors.black,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...highlights.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check, color: ThemeColors.green, size: 18.sp),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: ThemeColors.inkMid,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
