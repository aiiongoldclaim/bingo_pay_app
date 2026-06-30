import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
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
    final s = value.truncate().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      final rem = fromEnd - 1;
      if (rem == 3 || (rem > 3 && (rem - 3) % 2 == 0)) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.ink.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ──────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Background + icon
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ThemeColors.surface2,
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
                                errorBuilder: (ctx, err, st) => _Fallback(
                                  icon: product.icon,
                                ),
                                loadingBuilder: (ctx, child, p) =>
                                    p == null
                                        ? child
                                        : _Fallback(icon: product.icon),
                              ),
                            )
                          : _Fallback(icon: product.icon),
                    ),
                  ),
                  // Badge top-left
                  if (product.badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Badge(label: product.badge!),
                    ),
                  // Heart top-right
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onFavouriteTap,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: ThemeColors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          product.isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 15.sp,
                          color: product.isFavourite
                              ? ThemeColors.red
                              : ThemeColors.inkDim,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Info area ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 1.2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: ThemeColors.inkDim,
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
                      color: ThemeColors.ink,
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
                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.price > 0
                                  ? '\$${_formatPrice(product.price)}'
                                  : 'N/A',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w800,
                                color: ThemeColors.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (product.originalPrice != null &&
                                product.originalPrice! > 0)
                              Text(
                                '\$${_formatPrice(product.originalPrice!)}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: ThemeColors.inkDim,
                                  fontSize: 14.sp,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      if (discount != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w,
                            vertical: 0.3.h,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-$discount%',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: ThemeColors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
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

class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColors.surface2,
      alignment: Alignment.center,
      child: Icon(icon, size: 15.w, color: ThemeColors.inkDim),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});
  bool get _isPercent => label.startsWith('-');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: _isPercent ? ThemeColors.ink : ThemeColors.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: ThemeColors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  final int? count;
  const _RatingPill({required this.rating, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
          decoration: BoxDecoration(
            color: ThemeColors.green,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(Icons.star, size: 13.sp, color: ThemeColors.white),
              SizedBox(width: 0.8.w),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.white,
                ),
              ),
            ],
          ),
        ),
        if (count != null) ...[
          SizedBox(width: 1.5.w),
          Text(
            '(${count! >= 1000 ? '${(count! / 1000).toStringAsFixed(1)}k' : count})',
            style: AppTextStyles.labelMedium.copyWith(color: ThemeColors.inkDim),
          ),
        ],
      ],
    );
  }
}
