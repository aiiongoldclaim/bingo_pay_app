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

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/category_entity.dart';
import 'categories_metrics.dart';
import 'category_tile.dart';

/// Column count and spacing for the category grid, picked from the width the
/// grid actually gets (not the screen), so phones, foldables, tablets and
/// landscape all land on a sensible card size.
class CategoryGridLayout {
  const CategoryGridLayout._({
    required this.columns,
    required this.spacing,
    required this.tileWidth,
  });

  final int columns;
  final double spacing;
  final double tileWidth;

  factory CategoryGridLayout.forWidth(double width) {
    final columns = switch (width) {
      < 340 => 3,
      < 600 => 4,
      < 860 => 5,
      < 1080 => 6,
      _ => 7,
    };
    final spacing = width < 600 ? 10.0 : 14.0;
    final tileWidth = (width - spacing * (columns - 1)) / columns;
    return CategoryGridLayout._(
      columns: columns,
      spacing: spacing,
      tileWidth: tileWidth,
    );
  }
}

/// Every category from the API as box cards. Built lazily as a sliver so a
/// long list only builds the cards on screen.
class CategoriesSliverGrid extends StatelessWidget {
  const CategoriesSliverGrid({
    super.key,
    required this.metrics,
    required this.categories,
    this.onCategoryTap,
  });

  final CategoriesMetrics metrics;
  final List<CategoryEntity> categories;
  final ValueChanged<CategoryEntity>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final layout = CategoryGridLayout.forWidth(
            constraints.crossAxisExtent,
          );
          final style = CategoryTileStyle.forWidth(layout.tileWidth);

          return SliverGrid.builder(
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.columns,
              crossAxisSpacing: layout.spacing,
              mainAxisSpacing: layout.spacing,
              mainAxisExtent: style.heightFor(
                layout.tileWidth,
                MediaQuery.textScalerOf(context),
              ),
            ),
            itemBuilder: (_, i) {
              final category = categories[i];
              return CategoryTile(
                key: ValueKey(category.uuid),
                category: category,
                style: style,
                onTap: () => onCategoryTap?.call(category),
              );
            },
          );
        },
      ),
    );
  }
}

/// Shown in place of the grid when there are no categories: an empty list
/// from the API, or a failed request ([isError]).
class CategoriesStateMessage extends StatelessWidget {
  const CategoriesStateMessage({
    super.key,
    required this.metrics,
    required this.isError,
    required this.onRetry,
    this.noun = 'categories',
  });

  final CategoriesMetrics metrics;
  final bool isError;
  final VoidCallback onRetry;

  /// What the grid lists, e.g. "sub-categories", used in the messages.
  final String noun;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final badge = m.categoryCircle;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m.pagePadding,
        vertical: m.sectionGap,
      ),
      child: Column(
        children: [
          Container(
            width: badge,
            height: badge,
            decoration: BoxDecoration(
              color: colors.brandSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isError ? Icons.cloud_off_rounded : Icons.category_outlined,
              size: badge * 0.45,
              color: colors.brand,
            ),
          ),
          SizedBox(height: m.pagePadding),
          Text(
            isError ? AppStrings.serverDownTitle : 'No $noun available',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: m.sectionTitleSize * 0.9,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: m.pagePadding * 0.4),
          Text(
            isError
                ? AppStrings.serverDownMessage
                : 'New $noun will show up here soon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: m.categoryNameSize,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: m.pagePadding),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: colors.brand,
              foregroundColor: colors.onBrand,
              minimumSize: const Size(140, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(m.searchRadius),
              ),
            ),
            child: Text(isError ? 'Try Again' : 'Refresh'),
          ),
        ],
      ),
    );
  }
}
