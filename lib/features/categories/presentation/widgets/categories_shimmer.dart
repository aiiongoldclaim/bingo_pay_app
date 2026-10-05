import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import 'categories_grid.dart';
import 'categories_metrics.dart';
import 'category_tile.dart';

/// Categories screen ka loading skeleton — real layout se match karta hai.
class CategoriesShimmer extends StatelessWidget {
  const CategoriesShimmer({super.key, required this.metrics});

  final CategoriesMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          // ── Header ────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.pagePadding,
              metrics.pagePadding * 0.5,
              metrics.pagePadding,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _Block(
                      width: metrics.pagePadding * 9,
                      height: metrics.logoSize,
                      colors: colors,
                    ),
                  ),
                ),
                _Block(
                  width: metrics.searchIconSize * 1.6,
                  height: metrics.searchIconSize * 1.6,
                  radius: metrics.searchIconSize,
                  colors: colors,
                ),
                SizedBox(width: metrics.pagePadding * 0.6),
                _Block(
                  width: metrics.searchIconSize * 1.6,
                  height: metrics.searchIconSize * 1.6,
                  radius: metrics.searchIconSize,
                  colors: colors,
                ),
              ],
            ),
          ),

          SizedBox(height: metrics.pagePadding * 0.9),

          // ── Search ────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
            child: _Block(
              width: double.infinity,
              height: metrics.searchHeight,
              radius: metrics.searchRadius,
              colors: colors,
            ),
          ),

          SizedBox(height: metrics.sectionGap),

          // ── Categories ────────────────────────────
          _SectionHeader(metrics: metrics, colors: colors),
          SizedBox(height: metrics.pagePadding * 0.9),
          CategoryGridSkeleton(metrics: metrics, colors: colors),

          SizedBox(height: metrics.sectionGap),

          // ── Top Brands ────────────────────────────
          _SectionHeader(metrics: metrics, colors: colors, showAction: true),
          SizedBox(height: metrics.pagePadding * 0.9),
          _BoxGrid(metrics: metrics, colors: colors),

          SizedBox(height: metrics.sectionGap),

          // ── Curated Collection ────────────────────
          _SectionHeader(metrics: metrics, colors: colors, showAction: true),
          SizedBox(height: metrics.pagePadding * 0.9),
          _CollectionRail(metrics: metrics, colors: colors),

          SizedBox(height: metrics.sectionGap),
        ],
      ),
    );
  }
}

// ── Section title + action ─────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.metrics,
    required this.colors,
    this.showAction = false,
  });

  final CategoriesMetrics metrics;
  final AppThemeColors colors;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Block(
            width: metrics.pagePadding * 7,
            height: metrics.sectionTitleSize * 1.2,
            colors: colors,
          ),
          if (showAction)
            _Block(
              width: metrics.pagePadding * 4,
              height: metrics.searchFontSize,
              colors: colors,
            ),
        ],
      ),
    );
  }
}

/// Sub-categories screen loading skeleton: "All products" tile, section
/// title, then the same box cards as the grid.
class SubCategoriesShimmer extends StatelessWidget {
  const SubCategoriesShimmer({super.key, required this.metrics});

  final CategoriesMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = metrics;

    return AppShimmer(
      backgroundColor: colors.background,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: m.pagePadding * 0.5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
            child: _Block(
              width: double.infinity,
              height: m.searchHeight,
              radius: m.searchRadius,
              colors: colors,
            ),
          ),
          SizedBox(height: m.sectionGap),
          _SectionHeader(metrics: m, colors: colors),
          SizedBox(height: m.pagePadding * 0.9),
          CategoryGridSkeleton(metrics: m, colors: colors),
        ],
      ),
    );
  }
}

// ── Categories: box cards, same layout as CategoriesSliverGrid ─────────────
class CategoryGridSkeleton extends StatelessWidget {
  const CategoryGridSkeleton({
    super.key,
    required this.metrics,
    required this.colors,
  });

  final CategoriesMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - metrics.pagePadding * 2;
        final layout = CategoryGridLayout.forWidth(width);
        final style = CategoryTileStyle.forWidth(layout.tileWidth);
        final height = style.heightFor(
          layout.tileWidth,
          MediaQuery.textScalerOf(context),
        );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
          child: Wrap(
            spacing: layout.spacing,
            runSpacing: layout.spacing,
            children: List.generate(
              layout.columns * 2,
              // Shaved slightly so float rounding can't push the last card
              // of a row onto the next line.
              (_) => _Block(
                width: layout.tileWidth - 0.5,
                height: height,
                radius: style.radius,
                colors: colors,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Brands: rounded boxes ──────────────────────────────────────────────────
class _BoxGrid extends StatelessWidget {
  const _BoxGrid({required this.metrics, required this.colors});

  final CategoriesMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = metrics.pagePadding * 0.7;
        final available = constraints.maxWidth - metrics.pagePadding * 2;
        final tileWidth = (available - spacing * 2) / 3;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(
              6,
                  (index) => _Block(
                width: tileWidth,
                height: tileWidth * 0.62,
                radius: metrics.searchRadius * 0.8,
                colors: colors,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Collections: horizontal cards ──────────────────────────────────────────
class _CollectionRail extends StatelessWidget {
  const _CollectionRail({required this.metrics, required this.colors});

  final CategoriesMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final cardWidth = metrics.pagePadding * 11;
    final cardHeight = cardWidth * 0.75;

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: metrics.pagePadding * 0.7),
        itemBuilder: (_, index) => _Block(
          width: cardWidth,
          height: cardHeight,
          radius: metrics.searchRadius,
          colors: colors,
        ),
      ),
    );
  }
}

// ── Building block ─────────────────────────────────────────────────────────
class _Block extends StatelessWidget {
  const _Block({
    required this.width,
    required this.height,
    required this.colors,
    this.radius = 6,
  });

  final double width;
  final double height;
  final double radius;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}