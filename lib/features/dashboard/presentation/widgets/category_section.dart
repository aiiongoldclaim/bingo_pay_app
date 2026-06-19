import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../data/models/category_model.dart';
import 'category_item.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key, required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by category',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 16.sp),
              ),

              Text(
                'See all',
                style: AppTextStyles.labelLarge.copyWith(
                  color: ThemeColors.blue,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        SizedBox(
          height: 16.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) =>
                CategoryItem(category: categories[index]),
            separatorBuilder: (_, __) => SizedBox(width: 3.w),
            itemCount: categories.length,
          ),
        ),
      ],
    );
  }
}
