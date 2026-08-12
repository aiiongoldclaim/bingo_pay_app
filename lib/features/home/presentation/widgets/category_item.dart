// import 'package:bingo_pay/core/constants/app_sizes.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../categories/data/models/categories_model.dart';
//
// class CategoryItem extends StatelessWidget {
//   const CategoryItem({super.key, required this.category, this.onTap});
//
//   final CategoryModel category;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 18.w,
//             height: 18.w,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//               color: category.color,
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: category.image != null
//                 ? Image.network(
//                     category.image!,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Icon(
//                       category.icon,
//                       color: ThemeColors.accent,
//                       size: 24.sp,
//                     ),
//                   )
//                 : Icon(category.icon, color: ThemeColors.accent, size: 24.sp),
//           ),
//
//           SizedBox(height: 1.h),
//
//           SizedBox(
//             width: 22.w,
//             child: Text(
//               category.name,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w700,
//                 color: ThemeColors.black.withOpacity(.9),
//               ),
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
import '../../../categories/data/models/categories_model.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.metrics,
    required this.category,
    this.isHighlighted = false,
    this.onTap,
  });

  final HomeMetrics metrics;
  final CategoryModel category;
  final bool isHighlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = isHighlighted ? c.brand : c.brand;
    final hasImage = category.image != null && category.image!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(metrics.categoryCircle),
      child: SizedBox(
        width: metrics.categoryCircle + 6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: metrics.categoryCircle,
              height: metrics.categoryCircle,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.categoryCircleBg,
                shape: BoxShape.circle,
              ),
              child: hasImage
                  ? ClipOval(
                      child: Image.network(
                        category.image!,
                        width: metrics.categoryIconSize,
                        height: metrics.categoryIconSize,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          category.icon,
                          size: metrics.categoryIconSize,
                          color: fg,
                        ),
                      ),
                    )
                  : Icon(
                      category.icon,
                      size: metrics.categoryIconSize,
                      color: fg,
                    ),
            ),
            SizedBox(height: metrics.pagePadding * 0.45),
            // CHANGED: maxLines 1 → 2, softWrap on, height tight
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: metrics.categoryLabelSize,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                height: 1.15,
                color: isHighlighted ? c.brand : c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
