import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(
        width: 45.w,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                radius: 2.8.h,
                child: Icon(Icons.favorite_border),
              ),
            ),

            Expanded(
              child: Center(
                child: Icon(product.icon, size: 12.w, color: AppColors.primary),
              ),
            ),

            Text(
              product.brand,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp),
            ),

            Text(product.name, maxLines: 2),

            SizedBox(height: .5.h),

            Text(
              product.price,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
