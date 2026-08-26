// import 'package:bingo_pay/features/categories/domain/entities/category_entity.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
// import 'categories_card.dart';
//
// class CategoriesGrid extends StatelessWidget {
//   const CategoriesGrid({super.key, required this.categories});
//
//   final List<CategoryEntity> categories;
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       itemCount: categories.length,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 4.w,
//         mainAxisSpacing: 2.h,
//         childAspectRatio: 1.08,
//       ),
//       itemBuilder: (_, index) {
//         final category = categories[index];
//         return CategoryCard(
//           category: category,
//           onTap: () => context.push(
//             '/product-listing/${Uri.encodeComponent(category.name)}',
//             extra: category.uuid,
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../domain/entities/category_entity.dart';
import 'categories_card.dart';
import 'categories_metrics.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({
    super.key,
    required this.metrics,
    required this.categories,
    this.maxRows = 2,
    this.onCategoryTap,
  });

  final CategoriesMetrics metrics;
  final List<CategoryEntity> categories;

  final int maxRows;
  final ValueChanged<CategoryEntity>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final m = metrics;
    final visible = categories.take(m.categoryColumns * maxRows).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: GridView.builder(
        itemCount: visible.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: m.categoryColumns,
          crossAxisSpacing: m.gridGap * 0.5,
          mainAxisSpacing: m.gridGap * 1.4,
          mainAxisExtent: m.categoryRowHeight,
        ),
        itemBuilder: (_, i) => CategoryCard(
          metrics: m,
          category: visible[i],
          onTap: () => onCategoryTap?.call(visible[i]),
        ),
      ),
    );
  }
}
