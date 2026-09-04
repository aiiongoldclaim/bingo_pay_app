import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';


class AppProductCard extends StatelessWidget {
  final String brand;
  final String productName;
  final String price;
  final String? oldPrice;
  final int? discountPercent;
  final String imageUrl;
  final String? rating;
  final String? badge;
  final bool isFavourite;
  final bool isInCart;
  final bool isAddingToCart;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavouriteChanged;
  final VoidCallback? onAddToCart;
  final bool isOutOfStock;

  const AppProductCard({
    super.key,
    required this.brand,
    required this.productName,
    required this.price,
    this.oldPrice,
    this.discountPercent,
    required this.imageUrl,
    this.rating,
    this.badge,
    this.isFavourite = false,
    this.isInCart = false,
    this.isAddingToCart = false,
    this.onTap,
    this.onFavouriteChanged,
    this.onAddToCart,
    this.isOutOfStock = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;

    final radius = isTablet ? 18.0 : 16.0;
    final pad = isTablet ? (isLandscape ? 12.0 : 14.0) : 3.w;
    final heartBox = isTablet ? (isLandscape ? 36.0 : 40.0) : 9.w;
    final heartIcon = isTablet ? (isLandscape ? 18.0 : 20.0) : 16.sp;
    final brandSize = isTablet ? (isLandscape ? 12.0 : 13.0) : 11.sp;
    final nameSize = isTablet ? (isLandscape ? 15.0 : 16.0) : 13.sp;
    final priceSize = isTablet ? (isLandscape ? 16.0 : 17.0) : 14.sp;
    final metaSize = isTablet ? (isLandscape ? 12.0 : 13.0) : 11.sp;
    final btnHeight = isTablet ? (isLandscape ? 36.0 : 40.0) : 4.4.h;
    final btnFont = isTablet ? (isLandscape ? 13.0 : 14.0) : 12.sp;
    final btnIcon = isTablet ? (isLandscape ? 16.0 : 17.0) : 14.sp;
    final gapXs = isTablet ? 4.0 : 0.5.h;
    final gapSm = isTablet ? 8.0 : 0.9.h;

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: c.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image + heart + badge ────────────────────────────────
              Padding(
                padding: EdgeInsets.all(pad * 0.6),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius * 0.75),
                          child: Container(
                            color: c.surfaceAlt,
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  size: heartBox * 1.1,
                                  color: c.textMuted,
                                ),
                              ),
                            )
                                : Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: heartBox * 1.1,
                                color: c.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (badge != null)
                        Positioned(
                          top: gapSm * 0.7,
                          left: gapSm * 0.7,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: gapSm * 0.9,
                              vertical: gapXs * 0.8,
                            ),
                            decoration: BoxDecoration(
                              color: c.brand,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge!,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: c.surface,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: metaSize - 1,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                      if (onFavouriteChanged != null)
                        Positioned(
                          top: gapSm * 0.6,
                          right: gapSm * 0.6,
                          child: GestureDetector(
                            onTap: () => onFavouriteChanged!(!isFavourite),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: heartBox,
                              height: heartBox,
                              decoration: BoxDecoration(
                                color: c.surface,
                                shape: BoxShape.circle,
                                boxShadow: c.isDark
                                    ? null
                                    : [
                                  BoxShadow(
                                    color: c.textPrimary.withValues(
                                      alpha: 0.10,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                isFavourite
                                    ? Icons.favorite
                                    : Icons.favorite_border_rounded,
                                size: heartIcon,
                                 color: isFavourite ? ThemeColors.red : c.textSecondary,
                                // color: ThemeColors.red,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Info ────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 0, pad, pad * 0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: brandSize,
                          letterSpacing: 0.3,
                          height: 1.2,
                        ),
                      ),

                      SizedBox(height: gapXs * 0.8),

                      Text(
                        productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: c.textPrimary,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: nameSize,
                          height: 1.25,
                        ),
                      ),

                      SizedBox(height: gapXs),

                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: c.textPrimary,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: priceSize,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (oldPrice != null && oldPrice!.isNotEmpty) ...[
                            SizedBox(width: gapXs * 1.4),
                            Text(
                              oldPrice!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: c.textMuted,
                                fontFamily: 'Inter',
                                fontSize: metaSize,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (discountPercent != null && discountPercent! > 0) ...[
                        SizedBox(height: gapXs * 0.5),
                        Text(
                          '$discountPercent% OFF',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: c.brand,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: metaSize,
                          ),
                        ),
                      ],

                      if (rating != null && rating!.isNotEmpty) ...[
                        SizedBox(height: gapXs),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: metaSize + 3,
                              color: c.brand,
                            ),
                            SizedBox(width: gapXs * 0.6),
                            Text(
                              rating!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: c.textSecondary,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: metaSize,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const Spacer(),

                      SizedBox(height: gapSm * 0.6),

                      // if (onAddToCart != null)
                      //   SizedBox(
                      //     height: btnHeight,
                      //     width: double.infinity,
                      //     child: Material(
                      //       color: isInCart ? c.brand : c.brandSoft,
                      //       borderRadius: BorderRadius.circular(10),
                      //       clipBehavior: Clip.antiAlias,
                      //       child: InkWell(
                      //         onTap: isAddingToCart ? null : onAddToCart,
                      //         child: Center(
                      //           child: isAddingToCart
                      //               ? SizedBox(
                      //             width: btnIcon,
                      //             height: btnIcon,
                      //             child: CircularProgressIndicator(
                      //               strokeWidth: 2,
                      //               valueColor: AlwaysStoppedAnimation(
                      //                 isInCart ? c.surface : c.brand,
                      //               ),
                      //             ),
                      //           )
                      //               : Row(
                      //             mainAxisAlignment:
                      //             MainAxisAlignment.center,
                      //             children: [
                      //               Icon(
                      //                 Icons.shopping_bag_outlined,
                      //                 size: btnIcon,
                      //                 color: isInCart
                      //                     ? c.surface
                      //                     : c.brand,
                      //               ),
                      //               SizedBox(width: gapXs * 1.2),
                      //               Flexible(
                      //                 child: Text(
                      //                   isInCart
                      //                       ? 'Go to Cart'
                      //                       : 'Add to Cart',
                      //                   maxLines: 1,
                      //                   overflow: TextOverflow.ellipsis,
                      //                   style: AppTextStyles.labelMedium
                      //                       .copyWith(
                      //                     color: isInCart
                      //                         ? c.surface
                      //                         : c.brand,
                      //                     fontFamily: 'Inter',
                      //                     fontWeight: FontWeight.w600,
                      //                     fontSize: btnFont,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      if (onAddToCart != null || isOutOfStock)
                        SizedBox(
                          height: btnHeight,
                          width: double.infinity,
                          child: Material(
                            color: isOutOfStock
                                ? c.surfaceAlt
                                : isInCart
                                ? c.brand
                                : c.brandSoft,
                            borderRadius: BorderRadius.circular(10),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: (isOutOfStock || isAddingToCart) ? null : onAddToCart,
                              child: Center(
                                child: isAddingToCart
                                    ? SizedBox(
                                  width: btnIcon,
                                  height: btnIcon,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      isInCart ? c.surface : c.brand,
                                    ),
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isOutOfStock
                                          ? Icons.remove_shopping_cart_outlined
                                          : Icons.shopping_bag_outlined,
                                      size: btnIcon,
                                      color: isOutOfStock
                                          ? c.textMuted
                                          : isInCart
                                          ? c.surface
                                          : c.brand,
                                    ),
                                    SizedBox(width: gapXs * 1.2),
                                    Flexible(
                                      child: Text(
                                        isOutOfStock
                                            ? 'Out of Stock'
                                            : isInCart
                                            ? 'Go to Cart'
                                            : 'Add to Cart',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelMedium.copyWith(
                                          color: isOutOfStock
                                              ? c.textMuted
                                              : isInCart
                                              ? c.surface
                                              : c.brand,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          fontSize: btnFont,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}