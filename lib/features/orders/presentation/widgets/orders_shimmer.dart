import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import 'orders_metrics.dart';

/// Orders list ka loading skeleton — filter tabs + order cards.
class OrdersShimmer extends StatelessWidget {
  const OrdersShimmer({super.key, required this.metrics});

  final OrdersMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: Column(
        children: [
          _FilterTabsSkeleton(metrics: metrics, colors: colors),

          SizedBox(height: metrics.sectionGap),

          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                metrics.pagePadding,
                0,
                metrics.pagePadding,
                metrics.sectionGap,
              ),
              itemCount: 4,
              separatorBuilder: (_, __) => SizedBox(height: metrics.sectionGap),
              itemBuilder: (_, index) =>
                  _OrderCardSkeleton(metrics: metrics, colors: colors),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter tabs ────────────────────────────────────────────────────────────
class _FilterTabsSkeleton extends StatelessWidget {
  const _FilterTabsSkeleton({required this.metrics, required this.colors});

  final OrdersMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: metrics.ctaHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: metrics.pagePadding * 0.5),
        itemBuilder: (_, index) => _Block(
          width: metrics.pagePadding * (index == 0 ? 4 : 5.5),
          height: metrics.ctaHeight,
          radius: metrics.ctaHeight * 0.5,
          colors: colors,
        ),
      ),
    );
  }
}

// ── Order card ─────────────────────────────────────────────────────────────
class _OrderCardSkeleton extends StatelessWidget {
  const _OrderCardSkeleton({required this.metrics, required this.colors});

  final OrdersMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(metrics.pagePadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order id + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Block(
                width: metrics.pagePadding * 7,
                height: metrics.productMetaSize * 1.3,
                colors: colors,
              ),
              _Block(
                width: metrics.pagePadding * 5,
                height: metrics.productMetaSize * 1.7,
                radius: 20,
                colors: colors,
              ),
            ],
          ),

          SizedBox(height: metrics.sectionGap * 0.7),

          // Thumbnail + product info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Block(
                width: metrics.thumbSize,
                height: metrics.thumbSize,
                radius: 10,
                colors: colors,
              ),
              SizedBox(width: metrics.pagePadding * 0.8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Block(
                      width: double.infinity,
                      height: metrics.productNameSize * 1.2,
                      colors: colors,
                    ),
                    SizedBox(height: metrics.sectionGap * 0.35),
                    _Block(
                      width: metrics.pagePadding * 8,
                      height: metrics.productMetaSize * 1.2,
                      colors: colors,
                    ),
                    SizedBox(height: metrics.sectionGap * 0.35),
                    _Block(
                      width: metrics.pagePadding * 5,
                      height: metrics.productNameSize * 1.2,
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: metrics.sectionGap * 0.8),

          Container(height: 1, color: colors.border),

          SizedBox(height: metrics.sectionGap * 0.8),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _Block(
                  width: double.infinity,
                  height: metrics.ctaHeight,
                  radius: 10,
                  colors: colors,
                ),
              ),
              SizedBox(width: metrics.pagePadding * 0.6),
              Expanded(
                child: _Block(
                  width: double.infinity,
                  height: metrics.ctaHeight,
                  radius: 10,
                  colors: colors,
                ),
              ),
            ],
          ),
        ],
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