import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'categories_metrics.dart';

class CatHeader extends StatelessWidget {
  const CatHeader({
    super.key,
    required this.metrics,
    required this.brandName,
    required this.tagline,
    this.cartCount = 0,
    this.onWishlistTap,
    this.onCartTap,
  });

  final CategoriesMetrics metrics;
  final String brandName;
  final String tagline;
  final int cartCount;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                brandName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.brandLogo.copyWith(
                  fontSize: m.logoSize,
                  color: c.brand,
                ),
              ),
              SizedBox(height: m.pagePadding * 0.15),
              Text(
                tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: m.taglineSize,
                  height: 1.2,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _HeaderIcon(
          icon: Icons.favorite_border_rounded,
          size: m.headerIconSize,
          color: c.textPrimary,
          onTap: onWishlistTap,
        ),
        SizedBox(width: m.pagePadding),
        _HeaderIcon(
          icon: Icons.shopping_bag_outlined,
          size: m.headerIconSize,
          color: c.textPrimary,
          badgeCount: cartCount,
          badgeColor: c.brand,
          onTap: onCartTap,
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.size,
    required this.color,
    this.onTap,
    this.badgeCount = 0,
    this.badgeColor,
  });

  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onTap;
  final int badgeCount;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: size, color: color),
          if (badgeCount > 0)
            Positioned(
              top: -size * 0.28,
              right: -size * 0.28,
              child: Container(
                width: size * 0.62,
                height: size * 0.62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
