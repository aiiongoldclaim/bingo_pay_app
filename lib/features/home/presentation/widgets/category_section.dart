import 'package:flutter/material.dart';

import '../../../categories/data/models/categories_model.dart';
import 'category_item.dart';
import 'category_view_all_tile.dart';
import 'home_metrics.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.metrics,
    required this.categories,
    this.onCategoryTap,
    this.onViewAll,
    this.viewAllLabel = 'View All',
  });

  final HomeMetrics metrics;
  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel>? onCategoryTap;
  final VoidCallback? onViewAll;
  final String viewAllLabel;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final slots = metrics.categoryPerRow - 1;
    final visible = categories.take(slots).toList();
    final hasMore = categories.length > slots;

    return SizedBox(
      height: metrics.categoryRowHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...visible.map(
              (cat) => CategoryItem(
                metrics: metrics,
                category: cat,
                onTap: () => onCategoryTap?.call(cat),
              ),
            ),
            if (hasMore || onViewAll != null)
              CategoryViewAllTile(
                metrics: metrics,
                label: viewAllLabel,
                onTap: onViewAll,
              ),
          ],
        ),
      ),
    );
  }
}
