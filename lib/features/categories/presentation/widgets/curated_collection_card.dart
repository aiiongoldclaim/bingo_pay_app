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
    this.imageUrl,
    this.ctaLabel = 'Explore',
    this.onTap,
  });

  final CategoriesMetrics metrics;
  final CuratedCollectionModel collection;

  /// `CuratedCollectionModel` me abhi image field nahi hai — screen se
  /// pass karo, ya model me add karke seedha yahan padho.
  final String? imageUrl;
  final String ctaLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.collectionRadius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(m.collectionRadius),
        child: Container(
          width: m.collectionWidth,
          height: m.collectionHeight,
          color: c.isDark ? c.surfaceAlt : collection.iconBg,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                Align(
                  alignment: Alignment.bottomRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.72,
                    heightFactor: 0.9,
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                )
              else
                Positioned(
                  right: -m.pagePadding * 0.4,
                  bottom: -m.pagePadding * 0.4,
                  child: Icon(
                    collection.icon,
                    size: m.collectionHeight * 0.46,
                    color: c.brand.withValues(alpha: c.isDark ? 0.22 : 0.15),
                  ),
                ),

              Padding(
                padding: EdgeInsets.all(m.pagePadding * 0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.collectionTitleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: m.pagePadding * 0.45),
                    SizedBox(
                      width: m.collectionWidth * 0.62,
                      child: Text(
                        collection.subtitle,
                        maxLines: 3,
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
                      height: m.collectionCtaHeight,
                      padding: EdgeInsets.symmetric(
                        horizontal: m.pagePadding * 0.8,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(
                          m.collectionCtaHeight,
                        ),
                        border: Border.all(color: c.brand, width: 1.2),
                      ),
                      child: Text(
                        ctaLabel,
                        style: TextStyle(
                          fontSize: m.collectionCtaSize,
                          fontWeight: FontWeight.w600,
                          color: c.brand,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
