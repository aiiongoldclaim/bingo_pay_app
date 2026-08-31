import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import 'products_metrics.dart';

/// Products grid ka loading skeleton.
class ProductsGridShimmer extends StatelessWidget {
  const ProductsGridShimmer({
    super.key,
    required this.metrics,
    this.itemCount,
  });

  final ProductsMetrics metrics;

  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return AppShimmer(
      backgroundColor: colors.background,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          metrics.pageHPad,
          metrics.gapMd,
          metrics.pageHPad,
          metrics.gapLg,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: metrics.crossAxisCount,
          crossAxisSpacing: metrics.gridSpacing,
          mainAxisSpacing: metrics.gridSpacing,
          childAspectRatio: metrics.cardAspectRatio,
        ),
        itemCount: itemCount ?? metrics.crossAxisCount * 3,
        itemBuilder: (context, index) => ProductCardSkeleton(metrics: metrics),
      ),
    );
  }
}

/// Single product card ka skeleton.
/// Alag se bhi use ho sakta hai (horizontal list, carousel etc.)
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({
    super.key,
    required this.metrics,
  });

  final ProductsMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              color: colors.surface,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(metrics.gapSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBar(width: 60, height: 10, colors: colors),
                SizedBox(height: metrics.gapXs),
                SkeletonBar(width: double.infinity, height: 12, colors: colors),
                SizedBox(height: metrics.gapXs),
                SkeletonBar(width: 100, height: 12, colors: colors),
                SizedBox(height: metrics.gapSm),
                SkeletonBar(width: 70, height: 14, colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable grey bar — text lines ki jagah.
class SkeletonBar extends StatelessWidget {
  const SkeletonBar({
    super.key,
    required this.width,
    required this.height,
    required this.colors,
    this.radius = 4,
  });

  final double width;
  final double height;
  final AppThemeColors colors;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}