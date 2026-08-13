// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../domain/entities/brand_entity.dart';
// import 'brand_chip.dart';
//
// class BrandsGrid extends StatelessWidget {
//   const BrandsGrid({
//     super.key,
//     required this.brands,
//     this.isLoading = false,
//     this.error,
//   });
//
//   final List<BrandEntity> brands;
//   final bool isLoading;
//   final String? error;
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return SizedBox(
//         height: 15.h,
//         child: GridView.builder(
//           itemCount: 6,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             crossAxisSpacing: 3.w,
//             mainAxisSpacing: 2.h,
//             childAspectRatio: 1.45,
//           ),
//           itemBuilder: (_, index) {
//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             );
//           },
//         ),
//       );
//     }
//
//     if (error != null) {
//       return Container(
//         padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFCE4EC),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.warning_outlined,
//               color: const Color(0xFFE91E63),
//               size: 24,
//             ),
//             SizedBox(height: 1.h),
//             Text(
//               'Failed to load brands',
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFFE91E63),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (brands.isEmpty) {
//       return SizedBox(
//         height: 10.h,
//         child: Center(
//           child: Text(
//             'No brands available',
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[600],
//             ),
//           ),
//         ),
//       );
//     }
//
//     return GridView.builder(
//       itemCount: brands.length,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 3.w,
//         mainAxisSpacing: 2.h,
//         childAspectRatio: 1.45,
//       ),
//       itemBuilder: (_, index) {
//         return BrandChip(brand: brands[index]);
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/brand_entity.dart';
import 'brand_chip.dart';
import 'categories_metrics.dart';

class BrandsGrid extends StatelessWidget {
  const BrandsGrid({
    super.key,
    required this.metrics,
    required this.brands,
    this.isLoading = false,
    this.error,
    this.onBrandTap,
  });

  final CategoriesMetrics metrics;
  final List<BrandEntity> brands;
  final bool isLoading;
  final String? error;
  final ValueChanged<BrandEntity>? onBrandTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    if (isLoading) {
      return SizedBox(
        height: m.brandRowHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
          itemCount: 5,
          separatorBuilder: (_, __) => SizedBox(width: m.gridGap),
          itemBuilder: (_, __) => Container(
            width: m.brandTileWidth,
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              borderRadius: BorderRadius.circular(m.categoryTileRadius),
            ),
          ),
        ),
      );
    }

    if (error != null) {
      return _Message(
        metrics: m,
        icon: Icons.error_outline_rounded,
        text: 'Failed to load brands',
        color: c.isDark ? c.textSecondary : const Color(0xFFE0533B),
      );
    }

    if (brands.isEmpty) {
      return _Message(
        metrics: m,
        icon: Icons.storefront_outlined,
        text: 'No brands available',
        color: c.textSecondary,
      );
    }

    return SizedBox(
      height: m.brandRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
        itemCount: brands.length,
        separatorBuilder: (_, __) => SizedBox(width: m.gridGap),
        itemBuilder: (_, i) => BrandChip(
          metrics: m,
          brand: brands[i],
          onTap: () => onBrandTap?.call(brands[i]),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.metrics,
    required this.icon,
    required this.text,
    required this.color,
  });

  final CategoriesMetrics metrics;
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m.pagePadding,
        vertical: m.pagePadding,
      ),
      child: Row(
        children: [
          Icon(icon, size: m.searchIconSize, color: color),
          SizedBox(width: m.pagePadding * 0.6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: m.brandNameSize * 1.1, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
