import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/product_details_model.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductDetailModel product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.w),
      color: ThemeColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.brand.toUpperCase(),
                style: AppTextStyles.labelMedium.copyWith(
                  color: ThemeColors.inkMid,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .2.h),
                decoration: BoxDecoration(
                  color: ThemeColors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: ThemeColors.white, size: 14.sp),
                    SizedBox(width: 1.w),
                    Text(
                      product.rating,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: ThemeColors.white,
                      ),
                    ),
                    Text(
                      " • ${product.reviewCount}",
                      style: AppTextStyles.labelLarge.copyWith(
                        color: ThemeColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // SizedBox(height: 1.h),
          Text(
            product.productName,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          // SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                product.price,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(width: 2.w),

              Text(
                product.oldPrice,
                style: AppTextStyles.bodyMedium.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
              ),

              SizedBox(width: 2.w),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .3.h),
                decoration: BoxDecoration(
                  color: ThemeColors.greenSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${product.discount}% OFF',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: ThemeColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.w),
            decoration: BoxDecoration(
              color: ThemeColors.accent1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white60,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 3.w,
                    backgroundColor: ThemeColors.accent,
                    child: Text(
                      "B",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.ink,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  "Earn 380 BINGOLD coins on this order",
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
