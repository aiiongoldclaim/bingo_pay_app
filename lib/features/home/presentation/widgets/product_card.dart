import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/product_model.dart';
import '../models/vault_theme_colors.dart';
import 'home_metrics.dart';
import '../../../../core/constants/app_strings.dart';


class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.metrics,
    required this.product,
    this.isWishlisted = false,
    this.isAddingToCart = false,
    this.isOutOfStock = false,
    this.onTap,
    this.onWishlistTap,
    this.onAddToCart,
    this.width,
    this.activeTheme,
  });

  final HomeMetrics metrics;
  final ProductModel product;
  final bool isWishlisted;
  final bool isAddingToCart;
  final bool isOutOfStock;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddToCart;
  final double? width;

  final VaultThemeColors? activeTheme;

  static const _animationDuration = Duration(milliseconds: 320);
  static const _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final theme = activeTheme;
    final m = metrics;
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';
    final hasOldPrice = product.oldPrice.isNotEmpty;
    final hasDiscount = product.discount > 0;
    final cardPad = theme != null ? m.pagePadding * 0.4 : 0.0;
    final isUltraLuxe = identical(theme, VaultThemeColors.ultraLuxe);
    final sizeScale = isUltraLuxe ? 1.12 : 1.0;
    final discountColor = theme?.text ?? colors.discount;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width ?? m.productCardWidth,
        child: AnimatedContainer(
          duration: _animationDuration,
          curve: _animationCurve,
          padding: EdgeInsets.all(cardPad),
          decoration: BoxDecoration(
            color: theme?.cardBackground ?? Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: theme != null
                ? Border.all(color: theme.border)
                : null,
          ),
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
                    color: theme?.sectionBackground ?? colors.surfaceAlt,
                    child: imageUrl.isEmpty
                        ? Icon(
                            product.icon,
                            size: m.categoryIconSize,
                            color: theme?.secondaryText ?? colors.textMuted,
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              product.icon,
                              size: m.categoryIconSize,
                              color: theme?.secondaryText ?? colors.textMuted,
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
                        padding: EdgeInsets.all(m.pagePadding * 0.6),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: m.searchIconSize,
                          color: isWishlisted
                              ? ThemeColors.red
                              : (theme?.text ?? colors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ),

                if (isOutOfStock)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: m.pagePadding * 0.25,
                      ),
                      decoration: BoxDecoration(
                        color: colors.textPrimary.withValues(alpha: 0.7),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.outOfStockTitleCase,
                        style: TextStyle(
                          fontSize: m.productNameSize * 0.85,
                          fontWeight: FontWeight.w700,
                          color: colors.surface,
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
                color: theme?.text ?? colors.textPrimary,
              ),
            ),

            SizedBox(height: m.pagePadding * 0.15),

            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.productNameSize * sizeScale,
                color: theme?.secondaryText ?? colors.textSecondary,
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
                    fontSize: m.productPriceSize * sizeScale,
                    fontWeight: FontWeight.w700,
                    color: theme?.text ?? colors.textPrimary,
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
                        fontSize: m.productNameSize * sizeScale,
                        color: theme?.secondaryText ?? colors.textMuted,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: theme?.secondaryText ?? colors.textMuted,
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
                        color: discountColor,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                // ── Add to cart ──
                Material(
                  color: isOutOfStock
                      ? (theme?.sectionBackground ?? colors.surfaceAlt)
                      : (theme?.button ?? colors.brand),
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: (isOutOfStock || isAddingToCart) ? null : onAddToCart,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: EdgeInsets.all(m.pagePadding * 0.35),
                      child: SizedBox(
                        width: m.searchIconSize * 0.85,
                        height: m.searchIconSize * 0.85,
                        child: isAddingToCart
                            ? CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  theme?.buttonText ?? Colors.white,
                                ),
                              )
                            : Icon(
                                isOutOfStock
                                    ? Icons.remove_shopping_cart_outlined
                                    : Icons.shopping_bag_outlined,
                                size: m.searchIconSize * 0.85,
                                color: isOutOfStock
                                    ? (theme?.secondaryText ?? colors.textMuted)
                                    : (theme?.buttonText ?? Colors.white),
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
      ),
    );
  }
}
