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
    required this.isSelected,
    required this.isSelecting,
    required this.onTap,
    required this.onLongPress,
    required this.onRemove,
    required this.onAddToCart,
  });

  final WishlistItem item;
  final bool isSelected;
  final bool isSelecting;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isSelected ? ThemeColors.blue : ThemeColors.line,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.ink.withOpacity(0.04),
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
                // Image area
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusLg - 1),
                    topRight: Radius.circular(AppSizes.radiusLg - 1),
                  ),
                  child: Container(
                    height: 17.h,
                    width: double.infinity,
                    color: ThemeColors.accentSoft.withOpacity(0.4),
                    child: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _PlaceholderIcon(),
                          )
                        : _PlaceholderIcon(),
                  ),
                ),

                // Badge
                if (item.badge != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _Badge(label: item.badge!),
                  ),

                // Discount pill
                if (item.discountPercent != null)
                  Positioned(
                    top: 10,
                    right: 38,
                    child: _DiscountPill(percent: item.discountPercent!),
                  ),

                // Remove / select button
                Positioned(
                  top: 8,
                  right: 8,
                  child: _TopRightButton(
                    isSelecting: isSelecting,
                    isSelected: isSelected,
                    onRemove: onRemove,
                  ),
                ),

                // Out of stock overlay
                if (!item.inStock)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusLg - 1),
                        topRight: Radius.circular(AppSizes.radiusLg - 1),
                      ),
                      child: Container(
                        color: ThemeColors.ink.withOpacity(0.45),
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
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
                  const SizedBox(height: 3),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  _RatingRow(rating: item.rating, count: item.reviewCount),
                  const SizedBox(height: 8),
                  _PriceRow(
                    price: item.formattedPrice,
                    original: item.formattedOriginal,
                    discountPercent: item.discountPercent,
                  ),
                  const SizedBox(height: 10),
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: item.inStock ? onAddToCart : null,
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
                        item.inStock ? 'Add to cart' : 'Notify me',
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

class _TopRightButton extends StatelessWidget {
  const _TopRightButton({
    required this.isSelecting,
    required this.isSelected,
    required this.onRemove,
  });

  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (isSelecting) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? ThemeColors.blue : ThemeColors.surface,
          border: Border.all(
            color: isSelected ? ThemeColors.blue : ThemeColors.inkDim,
            width: 2,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check_rounded,
                size: 14,
                color: ThemeColors.white,
              )
            : null,
      );
    }

    return GestureDetector(
      onTap: onRemove,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: ThemeColors.surface,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 16,
          color: ThemeColors.inkMid,
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, required this.count});
  final double rating;
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
              rating.toStringAsFixed(1),
              style: AppTextStyles.labelSmall.copyWith(
                color: ThemeColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 6),
      Text('(${_fmt(count)})', style: AppTextStyles.bodySmall),
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
  final String original;
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
      if (original.isNotEmpty)
        Text(
          original,
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
