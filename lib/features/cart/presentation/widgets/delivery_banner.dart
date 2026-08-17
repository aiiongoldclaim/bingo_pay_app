// import 'package:flutter/material.dart';
//
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// class FreeDeliveryBanner extends StatelessWidget {
//   const FreeDeliveryBanner({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: ThemeColors.greenSoft,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.local_shipping_outlined, color: ThemeColors.green),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "You've unlocked free delivery on this order",
//               style: AppTextStyles.labelLarge.copyWith(
//                 color: ThemeColors.green,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'cart_metrics.dart';

class FreeDeliveryBanner extends StatelessWidget {
  const FreeDeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = CartMetrics.of(context);

    return Container(
      padding: EdgeInsets.all(m.bannerPad),
      decoration: BoxDecoration(
        color: c.brandSoft,
        borderRadius: BorderRadius.circular(m.bannerRadius),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: m.bannerIconBox,
            height: m.bannerIconBox,
            decoration: BoxDecoration(
              color: c.surface.withValues(alpha: c.isDark ? 0.08 : 0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.local_shipping_outlined,
              size: m.bannerIconSize,
              color: c.brand,
            ),
          ),

          SizedBox(width: m.bannerPad * 0.8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Yay! You are getting free delivery',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.bannerTitleSize,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.6),
                Text(
                  'Add more items to unlock extra savings',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
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
                    backgroundColor: c.border,
                    valueColor: AlwaysStoppedAnimation(c.brand),
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
