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
    required this.imageUrl,
    this.width,
    this.onTap,
    this.initialFavourite = false,
    this.onFavouriteChanged,
    required this.rating,
  });

  final String brand;
  final String productName;
  final String price;
  final String imageUrl;
  final String rating;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Container(
            width: 44.w,
            decoration: BoxDecoration(
              color: ThemeColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.black.withOpacity(.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: Container(
                          width: double.infinity,
                          color: ThemeColors.white,
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: Image.network(
                              widget.imageUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 10.sp,
                      right: 10.sp,
                      child: GestureDetector(
                        onTap: _toggleFavourite,
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.radiusXs),
                          decoration: BoxDecoration(
                            color: ThemeColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavourite
                                ? ThemeColors.red
                                : ThemeColors.inkDim,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.brand,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: ThemeColors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      // SizedBox(height: .5.h),
                      Text(
                        widget.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(height: 1.2),
                      ),

                      SizedBox(height: .2.h),

                      /// 5 STAR RATING
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: .5.h),

                      Text(
                        '${CurrencyConstants.dollar}${widget.price}',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.black,
                        ),
                      ),
                    ],
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
