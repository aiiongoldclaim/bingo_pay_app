import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/app_sizes.dart';
import '../constants/currency_constants.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_colors.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.brand,
    required this.productName,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.rating,
    required this.icon,
    this.reviewCount = '(4.9k)',
    this.onTap,
    this.initialFavourite = false,
    this.onFavouriteChanged,
    this.width,
  });

  final String brand;
  final String productName;
  final String price;
  final String oldPrice;
  final int discount;
  final String rating;
  final String reviewCount;
  final IconData icon;

  final double? width;
  final VoidCallback? onTap;

  final bool initialFavourite;
  final ValueChanged<bool>? onFavouriteChanged;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavourite;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.initialFavourite;
  }

  void _toggleFavourite() {
    setState(() {
      isFavourite = !isFavourite;
    });

    widget.onFavouriteChanged?.call(isFavourite);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.width ?? 44.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// TOP CONTAINER
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: ThemeColors.surface2,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusMd),
                  topRight: Radius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w,
                          vertical: .6.h,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.accent,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                        ),
                        child: Text(
                          '-${widget.discount}%',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.black,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: _toggleFavourite,
                        child: CircleAvatar(
                          radius: 2.4.h,
                          backgroundColor: Colors.grey.shade100,
                          child: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18.sp,
                            color: isFavourite
                                ? ThemeColors.red
                                : ThemeColors.inkMid,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Center(
                    child: Icon(
                      widget.icon,
                      size: 20.w,
                      color: ThemeColors.blue,
                    ),
                  ),
                ],
              ),
            ),

            /// BOTTOM CONTAINER
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: ThemeColors.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppSizes.radiusMd),
                  bottomRight: Radius.circular(AppSizes.radiusMd),
                ),
                border: Border.all(
                  color: ThemeColors.black.withOpacity(0.5),
                  width: .5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.brand.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 16.sp,
                      color: ThemeColors.inkDim,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Text(
                    widget.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: .4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: ThemeColors.white,
                              size: 15.sp,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              widget.rating,
                              style: TextStyle(
                                color: ThemeColors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 1.w),

                      Text(
                        widget.reviewCount,
                        style: TextStyle(
                          color: ThemeColors.inkMid,
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  Row(
                    children: [
                      Text(
                        '${CurrencyConstants.dollar}${widget.price}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.black,
                        ),
                      ),

                      SizedBox(width: 2.w),

                      Text(
                        widget.oldPrice,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: ThemeColors.inkMid,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),

                      Spacer(),

                      Text(
                        '${widget.discount}%',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 15.sp,
                          color: ThemeColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
