import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../product_details/data/models/product_details_model.dart';

class FlashDealCard extends StatefulWidget {
  const FlashDealCard({super.key, required this.product, this.onTap});

  final ProductDetailModel product;
  final VoidCallback? onTap;

  @override
  State<FlashDealCard> createState() => _FlashDealCardState();
}

class _FlashDealCardState extends State<FlashDealCard> {
  bool _isFavourite = false;

  void _toggleFavourite() {
    setState(() {
      _isFavourite = !_isFavourite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 44.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ── Container 1: Discount + Heart + Product Icon ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: ThemeColors.surface2,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Discount + Heart Row
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '-${widget.product.discount}%',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.black,
                          ),
                        ),
                      ),

                      /// ✅ Tappable heart button
                      GestureDetector(
                        onTap: _toggleFavourite,
                        child: CircleAvatar(
                          radius: 2.4.h,
                          backgroundColor: Colors.grey.shade100,
                          child: Icon(
                            _isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18.sp,
                            color: _isFavourite ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // SizedBox(height: 2.h),

                  /// Product Icon
                  SizedBox(
                    height: 12.h,
                    width: double.infinity,
                    child: Center(
                      child: Icon(
                        widget.product.icon,
                        size: 20.w,
                        color: ThemeColors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ── Container 2: All Text ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Brand
                  Text(
                    widget.product.brand.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 15.sp,
                      color: ThemeColors.inkDim,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),

                  /// Product Name
                  Text(
                    widget.product.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  /// Rating
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: .4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 15.sp),
                            SizedBox(width: 1.w),
                            Text(
                              widget.product.rating,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '(4.9k)',
                        style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  /// Price Row
                  Row(
                    children: [
                      Text(
                        widget.product.price,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Flexible(
                        child: Text(
                          widget.product.oldPrice,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${widget.product.discount}%',
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
