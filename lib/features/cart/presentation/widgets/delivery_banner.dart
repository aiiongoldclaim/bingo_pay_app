import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'cart_metrics.dart';

class FreeDeliveryBanner extends StatelessWidget {
  const FreeDeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = CartMetrics.of(context);

    return Container(
      padding: EdgeInsets.all(m.bannerPad),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(m.bannerRadius),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: m.bannerIconBox,
            height: m.bannerIconBox,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: colors.isDark ? 0.08 : 0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.local_shipping_outlined,
              size: m.bannerIconSize,
              color: colors.brand,
            ),
          ),

          SizedBox(width: m.bannerPad * 0.8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.freeDeliveryUnlockedTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.bannerTitleSize,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.6),
                Text(
                  AppStrings.freeDeliverySubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.bannerSubSize,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: m.gapSm * 0.8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(m.progressHeight),
                  child: LinearProgressIndicator(
                    value: 0.72,
                    minHeight: m.progressHeight,
                    backgroundColor: colors.border,
                    valueColor: AlwaysStoppedAnimation(colors.brand),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
