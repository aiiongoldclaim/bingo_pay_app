import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'cart_metrics.dart';

// ── Title + subtitle + "Move All to Wishlist" ─────────────────────────────
class CartTitleBlock extends StatelessWidget {
  final CartMetrics metrics;
  final int totalItems;
  final VoidCallback onMoveAll;

  const CartTitleBlock({
    super.key,
    required this.metrics,
    required this.totalItems,
    required this.onMoveAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            AppStrings.cartItemsInBag(totalItems),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: m.pageSubtitleSize,
              height: 1.2,
            ),
          ),
        ),
        InkWell(
          onTap: onMoveAll,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: m.gapSm * 0.6,
              vertical: m.gapXs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: m.linkSize + 3,
                  color: colors.brand,
                ),
                SizedBox(width: m.gapSm * 0.5),
                Text(
                  AppStrings.moveAllToWishlist,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: m.linkSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
