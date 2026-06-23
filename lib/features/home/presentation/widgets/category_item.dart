import 'package:bingo_pay/core/constants/app_sizes.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../data/models/category_model.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 18.w,
          height: 18.w,
          margin: EdgeInsets.symmetric(horizontal: 0.5.h),
          decoration: BoxDecoration(
            color: category.backgroundColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(category.icon, color: category.iconColor, size: 24.sp),
        ),

        SizedBox(height: 1.h),

        Text(
          category.title,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: ThemeColors.black.withOpacity(.9),
          ),
        ),
      ],
    );
  }
}
