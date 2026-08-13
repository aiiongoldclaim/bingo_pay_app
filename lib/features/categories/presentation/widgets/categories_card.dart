// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../categories/data/models/categories_model.dart';
// import '../../domain/entities/category_entity.dart';
//
// class CategoryCard extends StatelessWidget {
//   const CategoryCard({
//     super.key,
//     required this.category,
//     this.onTap,
//     this.height,
//   });
//
//   final CategoryEntity category;
//   final VoidCallback? onTap;
//   final double? height;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//       onTap: onTap,
//       child: Container(
//         height: height ?? 16.h,
//         decoration: BoxDecoration(
//           color: category.color,
//           borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: category.image != null
//                   ? Image.network(
//                       category.image!,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, e, st) => _PlaceholderIcon(
//                         icon: category.icon,
//                         color: category.color,
//                       ),
//                       loadingBuilder: (_, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return _PlaceholderIcon(
//                           icon: category.icon,
//                           color: category.color,
//                         );
//                       },
//                     )
//                   : _PlaceholderIcon(
//                       icon: category.icon,
//                       color: category.color,
//                     ),
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: AppSizes.paddingSm,
//                 vertical: AppSizes.paddingSm,
//               ),
//               child: Text(
//                 category.name,
//                 style: AppTextStyles.titleLarge,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _PlaceholderIcon extends StatelessWidget {
//   const _PlaceholderIcon({required this.icon, required this.color});
//
//   final IconData icon;
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: color,
//       alignment: Alignment.center,
//       child: Icon(icon, color: ThemeColors.accent, size: 25.sp),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/category_entity.dart';
import 'categories_metrics.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.metrics,
    required this.category,
    this.itemCount,
    this.onTap,
  });

  final CategoriesMetrics metrics;
  final CategoryEntity category;

  /// e.g. "1200+ Items" — null hoga to line render nahi hogi
  final String? itemCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final hasImage = category.image != null && category.image!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.categoryTileRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: m.pagePadding * 0.4,
          vertical: m.pagePadding * 0.7,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.categoryTileRadius),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: m.categoryCircle,
              height: m.categoryCircle,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              child: hasImage
                  ? ClipOval(
                      child: Image.network(
                        category.image!,
                        width: m.categoryIconSize,
                        height: m.categoryIconSize,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          category.icon,
                          size: m.categoryIconSize,
                          color: c.brand,
                        ),
                      ),
                    )
                  : Icon(
                      category.icon,
                      size: m.categoryIconSize,
                      color: c.brand,
                    ),
            ),
            SizedBox(height: m.pagePadding * 0.55),
            Flexible(
              child: Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: m.categoryNameSize,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: c.textPrimary,
                ),
              ),
            ),
            if (itemCount != null && itemCount!.isNotEmpty) ...[
              SizedBox(height: m.pagePadding * 0.25),
              Flexible(
                child: Text(
                  itemCount!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.categoryCountSize,
                    height: 1.2,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
