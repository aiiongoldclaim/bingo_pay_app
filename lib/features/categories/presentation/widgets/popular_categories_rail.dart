import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/category_entity.dart';
import 'categories_metrics.dart';

class PopularCategoriesRail extends StatelessWidget {
  const PopularCategoriesRail({
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
    if (categories.isEmpty) return const SizedBox.shrink();
    final m = metrics;

    return SizedBox(
      height: m.popularRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: m.gridGap),
        itemBuilder: (_, i) => _PopularTile(
          metrics: m,
          category: categories[i],
          onTap: () => onCategoryTap?.call(categories[i]),
        ),
      ),
    );
  }
}

class _PopularTile extends StatelessWidget {
  const _PopularTile({
    required this.metrics,
    required this.category,
    this.onTap,
  });

  final CategoriesMetrics metrics;
  final CategoryEntity category;
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
        width: m.popularTileWidth,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.categoryTileRadius),
          border: Border.all(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: m.popularImageHeight,
              child: hasImage
                  ? Image.network(
                      category.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: c.surfaceAlt,
                        alignment: Alignment.center,
                        child: Icon(
                          category.icon,
                          size: m.categoryIconSize,
                          color: c.brand,
                        ),
                      ),
                    )
                  : Container(
                      color: c.surfaceAlt,
                      alignment: Alignment.center,
                      child: Icon(
                        category.icon,
                        size: m.categoryIconSize,
                        color: c.brand,
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: m.pagePadding * 0.5,
                vertical: m.pagePadding * 0.5,
              ),
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: m.popularNameSize,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: c.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
