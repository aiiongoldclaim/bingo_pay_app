// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
//
// class PromoBanner extends StatelessWidget {
//   const PromoBanner({
//     super.key,
//     required this.title,
//     required this.heading,
//     required this.buttonText,
//     this.onTap,
//     this.icon = Icons.card_giftcard_rounded,
//   });
//
//   final String title;
//   final String heading;
//   final String buttonText;
//   final VoidCallback? onTap;
//   final IconData icon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 5.w),
//       height: 22.h,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: ThemeColors.accent,
//         borderRadius: BorderRadius.circular(AppSizes.cardRadius),
//       ),
//       child: Stack(
//         children: [
//           /// Background Gift Icon
//           Positioned(
//             right: -2.w,
//             bottom: -2.h,
//             child: Icon(
//               icon,
//               size: 28.w,
//               color: ThemeColors.white.withOpacity(.25),
//             ),
//           ),
//
//           /// Content
//           Padding(
//             padding: EdgeInsets.all(AppSizes.paddingLg.toDouble()),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title.toUpperCase(),
//                   style: AppTextStyles.bannerTitle.copyWith(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//
//                 SizedBox(height: 0.8.h),
//
//                 Expanded(
//                   child: Text(
//                     heading,
//                     style: AppTextStyles.bannerHeading.copyWith(
//                       fontSize: 20.sp,
//                       color: ThemeColors.accentInk,
//                     ),
//                   ),
//                 ),
//
//                 GestureDetector(
//                   onTap: onTap,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 5.w,
//                       vertical: 1.4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: ThemeColors.accentInk,
//                       borderRadius: BorderRadius.circular(AppSizes.radiusXl),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           buttonText,
//                           style: AppTextStyles.buttonText.copyWith(
//                             fontSize: 15.sp,
//                             color: ThemeColors.white,
//                           ),
//                         ),
//                         SizedBox(width: 2.w),
//                         Icon(
//                           Icons.arrow_forward_rounded,
//                           color: ThemeColors.white,
//                           size: AppSizes.iconMd,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'home_metrics.dart';

import 'home_banner_data.dart';
import 'home_metrics.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.metrics,
    required this.banner,
    this.onTap,
  });

  final HomeMetrics metrics;
  final HomeBannerData banner;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return ClipRRect(
      borderRadius: BorderRadius.circular(metrics.heroRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: c.heroBanner),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Right-side artwork ────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.48,
                heightFactor: 1,
                child: Image.asset(
                  banner.imageAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ── Text block ────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.pagePadding,
                vertical: metrics.pagePadding * 0.85,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.56,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (banner.eyebrow.isNotEmpty) ...[
                      Text(
                        banner.eyebrow.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: metrics.heroEyebrowSize,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                          color: c.textSecondary,
                        ),
                      ),
                      SizedBox(height: metrics.pagePadding * 0.4),
                    ],

                    // FittedBox = title kabhi overflow nahi karega
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          banner.title,
                          style: TextStyle(
                            fontSize: metrics.heroTitleSize,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    if (banner.subtitle.isNotEmpty) ...[
                      SizedBox(height: metrics.pagePadding * 0.45),
                      Flexible(
                        child: Text(
                          banner.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: metrics.heroBodySize,
                            height: 1.4,
                            color: c.textPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: metrics.pagePadding * 0.7),

                    // Button ko fixed height do, minimumSize se nahi
                    SizedBox(
                      height: metrics.searchHeight * 0.72,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.brand,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.symmetric(
                            horizontal: metrics.pagePadding * 0.95,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          banner.ctaLabel.toUpperCase(),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: metrics.heroBodySize * 0.95,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
