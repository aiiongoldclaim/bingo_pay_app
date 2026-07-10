import 'package:bingo_pay/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/currency_constants.dart';
import '../../data/models/product_details_model.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductDetailModel product;
  final int quantity;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
  });

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
              if(product.rating.isNotEmpty && product.reviewCount.isNotEmpty && product.rating != "0.0" && product.reviewCount != "0")
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
                      " • (${product.reviewCount} reviews)",
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.availableStock <= 0)
                    Padding(
                      padding: EdgeInsets.only(bottom: .6.h),
                      child: _StockPill(
                        icon: Icons.error_outline_rounded,
                        label: 'Out of Stock',
                        color: ThemeColors.red,
                      ),
                    )
                  else if (product.availableStock <= 3)
                    Padding(
                      padding: EdgeInsets.only(bottom: .6.h),
                      child: _StockPill(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Only ${product.availableStock} left',
                        color: ThemeColors.amber,
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
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D4E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onDecrementQuantity,
                      icon: const Icon(Icons.remove, color: Colors.white),
                      iconSize: 18.sp,
                      padding: EdgeInsets.all(0.5.h),
                      constraints: BoxConstraints(minWidth: 3.5.h, minHeight: 2.8.h),
                    ),
                    Text(
                      quantity.toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: onIncrementQuantity,
                      icon: const Icon(Icons.add, color: Colors.white),
                      iconSize: 18.sp,
                      padding: EdgeInsets.all(0.5.h),
                      constraints: BoxConstraints(minWidth: 3.5.h, minHeight: 2.8.h),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StockPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: .4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 1.w),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
