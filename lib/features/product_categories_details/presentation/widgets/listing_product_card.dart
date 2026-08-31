// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../../core/theme/theme_colors.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../data/models/product_categories_model.dart';
//
// class ListingProductCard extends StatelessWidget {
//   final ListingProductModel product;
//   final VoidCallback? onTap;
//   final VoidCallback? onFavouriteTap;
//
//   const ListingProductCard({
//     super.key,
//     required this.product,
//     this.onTap,
//     this.onFavouriteTap,
//   });
//
//   String _formatPrice(double value) {
//     final s = value.truncate().toString();
//     final buf = StringBuffer();
//     for (int i = 0; i < s.length; i++) {
//       final fromEnd = s.length - i;
//       buf.write(s[i]);
//       final rem = fromEnd - 1;
//       if (rem == 3 || (rem > 3 && (rem - 3) % 2 == 0)) buf.write(',');
//     }
//     return buf.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final discount = product.discountPercent;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: ThemeColors.surface,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: ThemeColors.ink.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//           border: Border.all(color: ThemeColors.inkDim, width: 0.5),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Image area ──────────────────────────────────────────────────
//             Expanded(
//               child: Stack(
//                 children: [
//                   // Background + icon
//                   Positioned.fill(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: ThemeColors.surface2,
//                         borderRadius: const BorderRadius.vertical(
//                           top: Radius.circular(16),
//                         ),
//                       ),
//                       alignment: Alignment.center,
//                       child: product.imageUrl != null
//                           ? ClipRRect(
//                               borderRadius: const BorderRadius.vertical(
//                                 top: Radius.circular(16),
//                               ),
//                               child: Image.network(
//                                 product.imageUrl!,
//                                 fit: BoxFit.contain,
//                                 errorBuilder: (ctx, err, st) => _Fallback(
//                                   icon: product.icon,
//                                 ),
//                                 loadingBuilder: (ctx, child, p) =>
//                                     p == null
//                                         ? child
//                                         : _Fallback(icon: product.icon),
//                               ),
//                             )
//                           : _Fallback(icon: product.icon),
//                     ),
//                   ),
//                   // Badge top-left
//                   if (product.badge != null)
//                     Positioned(
//                       top: 8,
//                       left: 8,
//                       child: _Badge(label: product.badge!),
//                     ),
//                   // Heart top-right
//                   Positioned(
//                     top: 6,
//                     right: 6,
//                     child: GestureDetector(
//                       onTap: onFavouriteTap,
//                       child: Container(
//                         width: 30,
//                         height: 30,
//                         decoration: const BoxDecoration(
//                           color: ThemeColors.white,
//                           shape: BoxShape.circle,
//                         ),
//                         alignment: Alignment.center,
//                         child: Icon(
//                           product.isFavourite
//                               ? Icons.favorite
//                               : Icons.favorite_border,
//                           size: 15.sp,
//                           color: product.isFavourite
//                               ? ThemeColors.red
//                               : ThemeColors.inkDim,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // ── Info area ───────────────────────────────────────────────────
//             Padding(
//               padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 1.2.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.brand,
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: ThemeColors.inkDim,
//                       letterSpacing: 0.5,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(height: 0.3.h),
//                   Text(
//                     product.name,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       color: ThemeColors.ink,
//                       fontWeight: FontWeight.w600,
//                       height: 1.3,
//                     ),
//                   ),
//                   SizedBox(height: 0.5.h),
//                   if (product.rating != null)
//                     _RatingPill(
//                       rating: product.rating!,
//                       count: product.ratingCount,
//                     ),
//                   SizedBox(height: 0.5.h),
//                   // Price row
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               product.price > 0
//                                   ? '\$${_formatPrice(product.price)}'
//                                   : 'N/A',
//                               style: AppTextStyles.titleMedium.copyWith(
//                                 fontSize: 14.5.sp,
//                                 fontWeight: FontWeight.w800,
//                                 color: ThemeColors.ink,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             if (product.originalPrice != null &&
//                                 product.originalPrice! > 0)
//                               Text(
//                                 '\$${_formatPrice(product.originalPrice!)}',
//                                 style: AppTextStyles.labelSmall.copyWith(
//                                   color: ThemeColors.inkDim,
//                                   fontSize: 14.sp,
//                                   decoration: TextDecoration.lineThrough,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                           ],
//                         ),
//                       ),
//                       if (discount != null)
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 1.5.w,
//                             vertical: 0.3.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: ThemeColors.green.withOpacity(0.12),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Text(
//                             '-$discount%',
//                             style: AppTextStyles.labelSmall.copyWith(
//                               color: ThemeColors.green,
//                               fontWeight: FontWeight.w700,
//                               fontSize: 13.sp,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _Fallback extends StatelessWidget {
//   const _Fallback({required this.icon});
//   final IconData icon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: ThemeColors.surface2,
//       alignment: Alignment.center,
//       child: Icon(icon, size: 15.w, color: ThemeColors.inkDim),
//     );
//   }
// }
//
// class _Badge extends StatelessWidget {
//   final String label;
//   const _Badge({required this.label});
//   bool get _isPercent => label.startsWith('-');
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
//       decoration: BoxDecoration(
//         color: _isPercent ? ThemeColors.ink : ThemeColors.accent,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 10.sp,
//           fontWeight: FontWeight.w700,
//           color: ThemeColors.white,
//           letterSpacing: 0.2,
//         ),
//       ),
//     );
//   }
// }
//
// class _RatingPill extends StatelessWidget {
//   final double rating;
//   final int? count;
//   const _RatingPill({required this.rating, this.count});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
//           decoration: BoxDecoration(
//             color: ThemeColors.green,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.star, size: 13.sp, color: ThemeColors.white),
//               SizedBox(width: 0.8.w),
//               Text(
//                 rating.toStringAsFixed(1),
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w700,
//                   color: ThemeColors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // if (count != null) ...[
//         //   SizedBox(width: 1.5.w),
//         //   Text(
//         //     '(${count! >= 1000 ? '${(count! / 1000).toStringAsFixed(1)}k' : count})',
//         //     style: AppTextStyles.labelMedium.copyWith(color: ThemeColors.inkDim),
//         //   ),
//         // ],
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../data/models/product_categories_model.dart';

class ListingProductCard extends StatelessWidget {
  final ListingProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavouriteTap;

  const ListingProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavouriteTap,
  });

  String _formatPrice(double value) {
    final digits = value.truncate().toString();
    final buffer = StringBuffer();
    for (int index = 0; index < digits.length; index++) {
      final fromEnd = digits.length - index;
      buffer.write(digits[index]);
      final remaining = fromEnd - 1;
      if (remaining == 3 || (remaining > 3 && (remaining - 3) % 2 == 0)) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final discount = product.discountPercent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 1),
          boxShadow: colors.isDark
              ? null
              : [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceAlt,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: product.imageUrl != null
                          ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              _Fallback(icon: product.icon),
                          loadingBuilder: (_, child, progress) =>
                          progress == null
                              ? child
                              : _Fallback(icon: product.icon),
                        ),
                      )
                          : _Fallback(icon: product.icon),
                    ),
                  ),

                  if (product.badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Badge(label: product.badge!),
                    ),

                  Positioned(
                    top: 6,
                    right: 6,
                    child: _FavouriteButton(
                      isFavourite: product.isFavourite,
                      onTap: onFavouriteTap,
                    ),
                  ),
                ],
              ),
            ),

            // ── Info area ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 1.2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colors.textSecondary,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 0.3.h),

                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 0.5.h),

                  if (product.rating != null)
                    _RatingPill(
                      rating: product.rating!,
                      count: product.ratingCount,
                    ),

                  SizedBox(height: 0.5.h),

                  _PriceRow(
                    price: product.price,
                    originalPrice: product.originalPrice,
                    discount: discount,
                    formatPrice: _formatPrice,
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

// ── Price + discount ───────────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final int? discount;
  final String Function(double) formatPrice;

  const _PriceRow({
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                price > 0 ? '\$${formatPrice(price)}' : 'N/A',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              if (originalPrice != null && originalPrice! > 0)
                Text(
                  '\$${formatPrice(originalPrice!)}',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textMuted,
                    fontSize: 14.sp,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: colors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        if (discount != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
            decoration: BoxDecoration(
              color: colors.statusSuccessSoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '-$discount%',
              style: AppTextStyles.labelSmall.copyWith(
                color: colors.statusSuccess,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Wishlist heart ─────────────────────────────────────────────────────────
class _FavouriteButton extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback? onTap;

  const _FavouriteButton({required this.isFavourite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          boxShadow: colors.isDark
              ? null
              : [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          isFavourite ? Icons.favorite : Icons.favorite_border,
          size: 15.sp,
          color: isFavourite ? colors.brand : colors.textSecondary,
        ),
      ),
    );
  }
}

// ── Image fallback ─────────────────────────────────────────────────────────
class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.surfaceAlt,
      alignment: Alignment.center,
      child: Icon(icon, size: 15.w, color: colors.textMuted),
    );
  }
}

// ── Corner badge ───────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  bool get _isPercent => label.startsWith('-');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: _isPercent ? colors.statusSuccess : colors.brand,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: colors.onBrand,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Rating pill ────────────────────────────────────────────────────────────
class _RatingPill extends StatelessWidget {
  final double rating;
  final int? count;

  const _RatingPill({required this.rating, this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
          decoration: BoxDecoration(
            color: colors.brandSoft,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 13.sp, color: colors.brand),
              SizedBox(width: 0.8.w),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.brand,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}