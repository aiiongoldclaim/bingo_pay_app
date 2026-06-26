import 'package:bingo_pay/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/currency_constants.dart';
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
                  fontSize: 16.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .2.h),
                decoration: BoxDecoration(
                  color: ThemeColors.green,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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

          Text(
            product.productName,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          Row(
            children: [
              Text(
                '${product.price}',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(width: 2.w),

              Text(
                '${product.oldPrice}',
                style: AppTextStyles.bodyMedium.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: ThemeColors.inkDim,
                ),
              ),

              SizedBox(width: 2.w),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .3.h),
                decoration: BoxDecoration(
                  color: ThemeColors.greenSoft,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
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


         
        ],
      ),
    );
  }
}
