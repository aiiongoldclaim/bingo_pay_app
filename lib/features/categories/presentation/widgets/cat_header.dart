import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'categories_metrics.dart';

class CatHeader extends StatelessWidget {
  const CatHeader({
    super.key,
    required this.metrics,
    required this.title,
    this.cartCount = 0,
    this.onWishlistTap,
    this.onCartTap,
  });

  final CategoriesMetrics metrics;
  final String title;
  final int cartCount;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: m.logoSize * 0.85,
              height: 1.15,
              color: colors.textPrimary,
            ),
          ),
        ),
        _HeaderIcon(
          icon: Icons.favorite_border_rounded,
          size: m.headerIconSize,
          color: colors.textPrimary,
          onTap: onWishlistTap,
        ),
        SizedBox(width: m.pagePadding),
        _HeaderIcon(
          icon: Icons.shopping_cart_outlined,
          size: m.headerIconSize,
          color: colors.textPrimary,
          badgeCount: cartCount,
          badgeColor: colors.brand,
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
