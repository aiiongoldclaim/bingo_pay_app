import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import 'categories_metrics.dart';

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Block(
                        width: metrics.pagePadding * 8,
                        height: metrics.sectionTitleSize * 1.4,
                        colors: colors,
                      ),
                      SizedBox(height: metrics.pagePadding * 0.4),
                      _Block(
                        width: metrics.pagePadding * 11,
                        height: metrics.searchFontSize,
                        colors: colors,
                      ),
                    ],
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
          _CircleGrid(metrics: metrics, colors: colors),

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

// ── Categories: circle + label ─────────────────────────────────────────────
class _CircleGrid extends StatelessWidget {
  const _CircleGrid({required this.metrics, required this.colors});

  final CategoriesMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final circleSize = metrics.pagePadding * 4;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
      child: Wrap(
        spacing: metrics.pagePadding,
        runSpacing: metrics.pagePadding,
        children: List.generate(
          8,
              (index) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Block(
                width: circleSize,
                height: circleSize,
                radius: circleSize,
                colors: colors,
              ),
              SizedBox(height: metrics.pagePadding * 0.4),
              _Block(
                width: circleSize * 0.8,
                height: metrics.searchFontSize * 0.85,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
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