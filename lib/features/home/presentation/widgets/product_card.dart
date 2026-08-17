import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/product_model.dart';
import 'home_metrics.dart';

// class ProductCard extends StatelessWidget {
//   const ProductCard({
//     super.key,
//     required this.metrics,
//     required this.product,
//     this.isWishlisted = false,
//     this.onTap,
//     this.onWishlistTap,
//     this.onAddToCart,
//     this.width,
//   });
//
//   final HomeMetrics metrics;
//   final ProductModel product;
//   final bool isWishlisted;
//   final VoidCallback? onTap;
//   final VoidCallback? onWishlistTap;
//   final VoidCallback? onAddToCart;
//   final double? width;
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final imageUrl = product.images.isNotEmpty ? product.images.first : '';
//     final hasOldPrice = product.oldPrice.isNotEmpty;
//     final hasDiscount = product.discount > 0;
//
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: SizedBox(
//         width: width ?? metrics.productCardWidth,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ── Image + wishlist ─────────────────────────
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Container(
//                     height: metrics.productImageHeight,
//                     width: double.infinity,
//                     color: c.surfaceAlt,
//                     child: imageUrl.isEmpty
//                         ? Icon(
//                             product.icon,
//                             size: metrics.categoryIconSize,
//                             color: c.textMuted,
//                           )
//                         : Image.network(
//                             imageUrl,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => Icon(
//                               product.icon,
//                               size: metrics.categoryIconSize,
//                               color: c.textMuted,
//                             ),
//                           ),
//                   ),
//                 ),
//                 Positioned(
//                   top: metrics.pagePadding * 0.45,
//                   right: metrics.pagePadding * 0.45,
//                   child: InkResponse(
//                     onTap: onWishlistTap,
//                     radius: metrics.searchIconSize,
//                     child: Icon(
//                       isWishlisted
//                           ? Icons.favorite_rounded
//                           : Icons.favorite_border_rounded,
//                       size: metrics.searchIconSize,
//                       color: isWishlisted ? c.brand : c.textPrimary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             SizedBox(height: metrics.pagePadding * 0.5),
//
//             // ── Brand ────────────────────────────────────
//             Text(
//               product.brand.toUpperCase(),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: metrics.productBrandSize,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.2,
//                 color: c.textPrimary,
//               ),
//             ),
//
//             SizedBox(height: metrics.pagePadding * 0.15),
//
//             // ── Name ─────────────────────────────────────
//             Text(
//               product.name,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: metrics.productNameSize,
//                 color: c.textSecondary,
//               ),
//             ),
//
//             SizedBox(height: metrics.pagePadding * 0.35),
//
//             // ── Price row ────────────────────────────────
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.baseline,
//               textBaseline: TextBaseline.alphabetic,
//               children: [
//                 Text(
//                   product.price,
//                   style: TextStyle(
//                     fontSize: metrics.productPriceSize,
//                     fontWeight: FontWeight.w700,
//                     color: c.textPrimary,
//                   ),
//                 ),
//                 if (hasOldPrice) ...[
//                   SizedBox(width: metrics.pagePadding * 0.3),
//                   Flexible(
//                     child: Text(
//                       product.oldPrice,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: metrics.productNameSize,
//                         color: c.textMuted,
//                         decoration: TextDecoration.lineThrough,
//                         decorationColor: c.textMuted,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//
//             SizedBox(height: metrics.pagePadding * 0.3),
//
//             // ── Discount + cart ──────────────────────────
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 if (hasDiscount)
//                   Flexible(
//                     child: Text(
//                       '${product.discount}% OFF',
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: metrics.productNameSize,
//                         fontWeight: FontWeight.w600,
//                         color: c.discount,
//                       ),
//                     ),
//                   )
//                 else
//                   const SizedBox.shrink(),
//                 InkWell(
//                   onTap: onAddToCart,
//                   borderRadius: BorderRadius.circular(6),
//                   child: Container(
//                     padding: EdgeInsets.all(metrics.pagePadding * 0.35),
//                     decoration: BoxDecoration(
//                       color: c.brand,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Icon(
//                       Icons.shopping_bag_outlined,
//                       size: metrics.searchIconSize * 0.85,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/product_model.dart';
import 'home_metrics.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.metrics,
    required this.product,
    this.isWishlisted = false,
    this.isAddingToCart = false,
    this.onTap,
    this.onWishlistTap,
    this.onAddToCart,
    this.width,
  });

  final HomeMetrics metrics;
  final ProductModel product;
  final bool isWishlisted;
  final bool isAddingToCart;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddToCart;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';
    final hasOldPrice = product.oldPrice.isNotEmpty;
    final hasDiscount = product.discount > 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width ?? m.productCardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: m.productImageHeight,
                    width: double.infinity,
                    color: c.surfaceAlt,
                    child: imageUrl.isEmpty
                        ? Icon(
                            product.icon,
                            size: m.categoryIconSize,
                            color: c.textMuted,
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              product.icon,
                              size: m.categoryIconSize,
                              color: c.textMuted,
                            ),
                          ),
                  ),
                ),

                // ── Wishlist: bada tap target, filled red when active ──
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onWishlistTap,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        // 44dp tap target — pehle sirf icon clickable tha
                        padding: EdgeInsets.all(m.pagePadding * 0.6),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: m.searchIconSize,
                          color: isWishlisted
                              ? const Color(0xFFE0533B)
                              : c.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: m.pagePadding * 0.5),

            Text(
              product.brand.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.productBrandSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: c.textPrimary,
              ),
            ),

            SizedBox(height: m.pagePadding * 0.15),

            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.productNameSize,
                color: c.textSecondary,
              ),
            ),

            SizedBox(height: m.pagePadding * 0.35),

            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  product.price,
                  style: TextStyle(
                    fontSize: m.productPriceSize,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                if (hasOldPrice) ...[
                  SizedBox(width: m.pagePadding * 0.3),
                  Flexible(
                    child: Text(
                      product.oldPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.productNameSize,
                        color: c.textMuted,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: c.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: m.pagePadding * 0.3),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasDiscount)
                  Flexible(
                    child: Text(
                      '${product.discount}% OFF',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.productNameSize,
                        fontWeight: FontWeight.w600,
                        color: c.discount,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                // ── Add to cart ──
                Material(
                  color: c.brand,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: isAddingToCart ? null : onAddToCart,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: EdgeInsets.all(m.pagePadding * 0.35),
                      child: SizedBox(
                        width: m.searchIconSize * 0.85,
                        height: m.searchIconSize * 0.85,
                        child: isAddingToCart
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.shopping_bag_outlined,
                                size: m.searchIconSize * 0.85,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
