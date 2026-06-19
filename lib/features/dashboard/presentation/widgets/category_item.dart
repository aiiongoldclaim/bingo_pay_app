import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../data/models/category_model.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22.w,
      child: Column(
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              color: category.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(category.icon, color: category.iconColor, size: 24.sp),
          ),

          SizedBox(height: 1.h),

          Text(
            category.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
