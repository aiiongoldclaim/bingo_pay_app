// lib/features/wishlist/widgets/wishlist_card.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../data/models/wishlist_model.dart';

class WishlistCard extends StatelessWidget {
  const WishlistCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final WishlistItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: ThemeColors.line),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.ink.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + overlays ──────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusLg - 1),
                    topRight: Radius.circular(AppSizes.radiusLg - 1),
                  ),
                  child: Container(
                    height: 14.h,
                    width: double.infinity,
                    color: ThemeColors.accentSoft.withValues(alpha: 0.4),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const _PlaceholderIcon(),
                          )
                        : const _PlaceholderIcon(),
                  ),
                ),

                if (item.badge != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _Badge(label: item.badge!),
                  ),

                if (item.discountPercent != null)
                  Positioned(
                    top: 10,
                    right: 38,
                    child: _DiscountPill(percent: item.discountPercent!),
                  ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: ThemeColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 16,
                        color: ThemeColors.red,
                      ),
                    ),
                  ),
                ),

                if (!item.inStock)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusLg - 1),
                        topRight: Radius.circular(AppSizes.radiusLg - 1),
                      ),
                      child: Container(
                        color: ThemeColors.ink.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Out of stock',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: ThemeColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Info ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.brand,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: ThemeColors.inkDim,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  _RatingRow(rating: item.rating, count: item.reviewCount),
                  const SizedBox(height: 6),
                  _PriceRow(
                    price: item.price,
                    original: item.originalPrice,
                    discountPercent: item.discountPercent,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: item.inStock ? onTap : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.blue,
                        disabledBackgroundColor: ThemeColors.line,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        item.inStock ? 'View Product' : 'Out of stock',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: ThemeColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) => Center(
    child: Icon(Icons.inventory_2_outlined, size: 48, color: ThemeColors.line),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: ThemeColors.accentInk,
      borderRadius: BorderRadius.circular(AppSizes.radiusXs),
    ),
    child: Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: ThemeColors.white,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _DiscountPill extends StatelessWidget {
  const _DiscountPill({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: ThemeColors.accentSoft,
      borderRadius: BorderRadius.circular(AppSizes.radiusXs),
    ),
    child: Text(
      '-$percent%',
      style: AppTextStyles.labelSmall.copyWith(
        color: ThemeColors.accentInk,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, required this.count});
  final String rating;
  final int count;

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: ThemeColors.green,
          borderRadius: BorderRadius.circular(AppSizes.radiusXs),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 11, color: ThemeColors.white),
            const SizedBox(width: 3),
            Text(
              rating,
              style: AppTextStyles.labelSmall.copyWith(
                color: ThemeColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      if (count > 0) ...[
        const SizedBox(width: 6),
        Text('(${_fmt(count)})', style: AppTextStyles.bodySmall),
      ],
    ],
  );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.price,
    required this.original,
    this.discountPercent,
  });

  final String price;
  final String? original;
  final int? discountPercent;

  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 6,
    children: [
      Text(
        price,
        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
      ),
      if (original != null && original!.isNotEmpty)
        Text(
          original!,
          style: AppTextStyles.bodySmall.copyWith(
            decoration: TextDecoration.lineThrough,
          ),
        ),
      if (discountPercent != null)
        Text(
          '$discountPercent% off',
          style: AppTextStyles.bodySmall.copyWith(
            color: ThemeColors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
    ],
  );
}
