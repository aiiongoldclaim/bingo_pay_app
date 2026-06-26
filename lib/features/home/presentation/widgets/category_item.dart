import 'package:bingo_pay/core/constants/app_sizes.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../categories/data/models/categories_model.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.category, this.onTap});

  final CategoryModel category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              color: category.color,
            ),
            clipBehavior: Clip.antiAlias,
            child: category.image != null
                ? Image.network(
                    category.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      category.icon,
                      color: ThemeColors.accent,
                      size: 24.sp,
                    ),
                  )
                : Icon(category.icon, color: ThemeColors.accent, size: 24.sp),
          ),

          SizedBox(height: 1.h),

          SizedBox(
            width: 22.w,
            child: Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: ThemeColors.black.withOpacity(.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
