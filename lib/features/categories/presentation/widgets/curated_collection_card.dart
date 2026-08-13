// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../data/models/categories_model.dart';
// import '../cubit/categories_state.dart';
//
// class CuratedCollectionCard extends StatelessWidget {
//   const CuratedCollectionCard({
//     super.key,
//     required this.collection,
//     this.onTap,
//   });
//
//   final CuratedCollectionModel collection;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//       child: Container(
//         padding: EdgeInsets.all(AppSizes.paddingMd),
//         decoration: BoxDecoration(
//           color: ThemeColors.surface,
//           borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//           border: Border.all(color: ThemeColors.line),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 14.w,
//               height: 14.w,
//               decoration: BoxDecoration(
//                 color: collection.iconBg,
//                 borderRadius: BorderRadius.circular(AppSizes.radiusLg),
//               ),
//               child: Icon(collection.icon, color: ThemeColors.accent),
//             ),
//
//             SizedBox(width: 4.w),
//
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(collection.title, style: AppTextStyles.titleLarge),
//                   Text(collection.subtitle, style: AppTextStyles.bodyMedium),
//                 ],
//               ),
//             ),
//
//             Icon(Icons.chevron_right, size: 24.sp, color: ThemeColors.inkDim),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/categories_model.dart';
import 'categories_metrics.dart';

class CuratedCollectionCard extends StatelessWidget {
  const CuratedCollectionCard({
    super.key,
    required this.metrics,
    required this.collection,
    this.onTap,
  });

  final CategoriesMetrics metrics;
  final CuratedCollectionModel collection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.categoryTileRadius),
      child: Container(
        width: m.collectionWidth,
        height: m.collectionHeight,
        padding: EdgeInsets.all(m.pagePadding * 0.85),
        decoration: BoxDecoration(
          // Har collection ka apna tint model se aata hai
          color: c.isDark ? c.surfaceAlt : collection.iconBg,
          borderRadius: BorderRadius.circular(m.categoryTileRadius),
          border: c.isDark ? Border.all(color: c.border) : null,
        ),
        child: Stack(
          children: [
            // Decorative icon — bottom-right
            Positioned(
              right: -m.pagePadding * 0.3,
              bottom: -m.pagePadding * 0.3,
              child: Icon(
                collection.icon,
                size: m.collectionHeight * 0.52,
                color: c.brand.withValues(alpha: c.isDark ? 0.22 : 0.16),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: m.collectionWidth * 0.6,
                  child: Text(
                    collection.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.collectionTitleSize,
                      fontWeight: FontWeight.w700,
                      height: 1.22,
                      color: c.isDark ? c.textPrimary : c.brand,
                    ),
                  ),
                ),
                SizedBox(height: m.pagePadding * 0.4),
                SizedBox(
                  width: m.collectionWidth * 0.58,
                  child: Text(
                    collection.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.collectionBodySize,
                      height: 1.35,
                      color: c.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: m.collectionFabSize,
                  height: m.collectionFabSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.brand,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: m.collectionFabSize * 0.52,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
