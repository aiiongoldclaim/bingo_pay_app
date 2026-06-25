import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../home/data/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.height,
  });

  final CategoryModel category;
  final VoidCallback? onTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
      onTap: onTap,
      child: Container(
        height: height ?? 16.h,
        padding: EdgeInsets.all(AppSizes.paddingMd),
        decoration: BoxDecoration(
          // color: category.color,
          borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(category.icon, color: ThemeColors.accent, size: 22.sp),

            const Spacer(),

            Text(
              category.title,
              style: AppTextStyles.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 0.2.h),

            // Text(
            //   category.items,
            //   style: AppTextStyles.bodyMedium,
            //   maxLines: 1,
            //   overflow: TextOverflow.ellipsis,
            // ),
          ],
        ),
      ),
    );
  }
}
