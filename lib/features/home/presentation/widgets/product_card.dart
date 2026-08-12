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
    this.onTap,
    this.onWishlistTap,
    this.onAddToCart,
    this.width,
  });

  final HomeMetrics metrics;
  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddToCart;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';
    final hasOldPrice = product.oldPrice.isNotEmpty;
    final hasDiscount = product.discount > 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width ?? metrics.productCardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image + wishlist ─────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: metrics.productImageHeight,
                    width: double.infinity,
                    color: c.surfaceAlt,
                    child: imageUrl.isEmpty
                        ? Icon(
                            product.icon,
                            size: metrics.categoryIconSize,
                            color: c.textMuted,
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              product.icon,
                              size: metrics.categoryIconSize,
                              color: c.textMuted,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: metrics.pagePadding * 0.45,
                  right: metrics.pagePadding * 0.45,
                  child: InkResponse(
                    onTap: onWishlistTap,
                    radius: metrics.searchIconSize,
                    child: Icon(
                      isWishlisted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: metrics.searchIconSize,
                      color: isWishlisted ? c.brand : c.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: metrics.pagePadding * 0.5),

            // ── Brand ────────────────────────────────────
            Text(
              product.brand.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: metrics.productBrandSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: c.textPrimary,
              ),
            ),

            SizedBox(height: metrics.pagePadding * 0.15),

            // ── Name ─────────────────────────────────────
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: metrics.productNameSize,
                color: c.textSecondary,
              ),
            ),

            SizedBox(height: metrics.pagePadding * 0.35),

            // ── Price row ────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  product.price,
                  style: TextStyle(
                    fontSize: metrics.productPriceSize,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                if (hasOldPrice) ...[
                  SizedBox(width: metrics.pagePadding * 0.3),
                  Flexible(
                    child: Text(
                      product.oldPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: metrics.productNameSize,
                        color: c.textMuted,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: c.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: metrics.pagePadding * 0.3),

            // ── Discount + cart ──────────────────────────
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
                        fontSize: metrics.productNameSize,
                        fontWeight: FontWeight.w600,
                        color: c.discount,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                InkWell(
                  onTap: onAddToCart,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: EdgeInsets.all(metrics.pagePadding * 0.35),
                    decoration: BoxDecoration(
                      color: c.brand,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: metrics.searchIconSize * 0.85,
                      color: Colors.white,
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
