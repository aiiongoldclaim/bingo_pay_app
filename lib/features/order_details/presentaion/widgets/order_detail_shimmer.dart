import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import 'order_details_metrics.dart';

/// Order detail ka loading skeleton — real sections se match karta hai.
class OrderDetailShimmer extends StatelessWidget {
  const OrderDetailShimmer({super.key, required this.metrics});

  final OrderDetailMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: metrics.sectionGap * 0.5),
        children: [
          _TitleBlockSkeleton(metrics: metrics, colors: colors),

          SizedBox(height: metrics.sectionGap),

          _TrackingCardSkeleton(metrics: metrics, colors: colors),

          SizedBox(height: metrics.sectionGap),

          _SectionLabel(metrics: metrics, colors: colors),
          SizedBox(height: metrics.sectionGap * 0.5),
          _CardSkeleton(
            metrics: metrics,
            colors: colors,
            lineCount: 3,
          ),

          SizedBox(height: metrics.sectionGap),

          _SectionLabel(metrics: metrics, colors: colors),
          SizedBox(height: metrics.sectionGap * 0.5),
          _ItemsCardSkeleton(metrics: metrics, colors: colors),

          SizedBox(height: metrics.sectionGap),

          _SectionLabel(metrics: metrics, colors: colors),
          SizedBox(height: metrics.sectionGap * 0.5),
          _PriceDetailsSkeleton(metrics: metrics, colors: colors),

          SizedBox(height: metrics.sectionGap),

          _CardSkeleton(metrics: metrics, colors: colors, lineCount: 2),

          SizedBox(height: metrics.sectionGap),
        ],
      ),
    );
  }
}

// ── Title + order id ───────────────────────────────────────────────────────
class _TitleBlockSkeleton extends StatelessWidget {
  const _TitleBlockSkeleton({required this.metrics, required this.colors});

  final OrderDetailMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Block(
            width: metrics.pagePadding * 10,
            height: metrics.pagePadding * 1.5,
            colors: colors,
          ),
          SizedBox(height: metrics.sectionGap * 0.5),
          Row(
            children: [
              _Block(
                width: metrics.pagePadding * 8,
                height: metrics.pagePadding,
                colors: colors,
              ),
              SizedBox(width: metrics.pagePadding * 0.5),
              _Block(
                width: metrics.pagePadding,
                height: metrics.pagePadding,
                colors: colors,
              ),
            ],
          ),
          SizedBox(height: metrics.sectionGap * 0.35),
          _Block(
            width: metrics.pagePadding * 11,
            height: metrics.pagePadding * 0.9,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

// ── Tracking timeline ──────────────────────────────────────────────────────
class _TrackingCardSkeleton extends StatelessWidget {
  const _TrackingCardSkeleton({required this.metrics, required this.colors});

  final OrderDetailMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return _Card(
      metrics: metrics,
      colors: colors,
      child: Column(
        children: List.generate(3, (index) {
          final isLast = index == 2;
          return Padding(
            padding: EdgeInsets.only(
              bottom: isLast ? 0 : metrics.sectionGap * 0.8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    _Block(
                      width: metrics.pagePadding * 1.2,
                      height: metrics.pagePadding * 1.2,
                      radius: metrics.pagePadding,
                      colors: colors,
                    ),
                    if (!isLast) ...[
                      SizedBox(height: metrics.sectionGap * 0.2),
                      _Block(
                        width: 2,
                        height: metrics.sectionGap * 1.2,
                        radius: 1,
                        colors: colors,
                      ),
                    ],
                  ],
                ),
                SizedBox(width: metrics.pagePadding * 0.8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Block(
                        width: metrics.pagePadding * 7,
                        height: metrics.pagePadding,
                        colors: colors,
                      ),
                      SizedBox(height: metrics.sectionGap * 0.3),
                      _Block(
                        width: metrics.pagePadding * 10,
                        height: metrics.pagePadding * 0.8,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Order items ────────────────────────────────────────────────────────────
class _ItemsCardSkeleton extends StatelessWidget {
  const _ItemsCardSkeleton({required this.metrics, required this.colors});

  final OrderDetailMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final thumbSize = metrics.pagePadding * 4.5;

    return _Card(
      metrics: metrics,
      colors: colors,
      child: Column(
        children: List.generate(2, (index) {
          return Column(
            children: [
              if (index > 0) ...[
                SizedBox(height: metrics.sectionGap * 0.7),
                Container(height: 1, color: colors.border),
                SizedBox(height: metrics.sectionGap * 0.7),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Block(
                    width: thumbSize,
                    height: thumbSize,
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
                          height: metrics.pagePadding,
                          colors: colors,
                        ),
                        SizedBox(height: metrics.sectionGap * 0.35),
                        _Block(
                          width: metrics.pagePadding * 6,
                          height: metrics.pagePadding * 0.85,
                          colors: colors,
                        ),
                        SizedBox(height: metrics.sectionGap * 0.35),
                        _Block(
                          width: metrics.pagePadding * 4,
                          height: metrics.pagePadding * 1.1,
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Price rows ─────────────────────────────────────────────────────────────
class _PriceDetailsSkeleton extends StatelessWidget {
  const _PriceDetailsSkeleton({required this.metrics, required this.colors});

  final OrderDetailMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return _Card(
      metrics: metrics,
      colors: colors,
      child: Column(
        children: [
          for (int index = 0; index < 4; index++) ...[
            if (index > 0) SizedBox(height: metrics.sectionGap * 0.55),
            if (index == 3) ...[
              Container(height: 1, color: colors.border),
              SizedBox(height: metrics.sectionGap * 0.55),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Block(
                  width: metrics.pagePadding * (index == 3 ? 5 : 7),
                  height: metrics.pagePadding * (index == 3 ? 1.1 : 0.9),
                  colors: colors,
                ),
                _Block(
                  width: metrics.pagePadding * (index == 3 ? 5 : 4),
                  height: metrics.pagePadding * (index == 3 ? 1.1 : 0.9),
                  colors: colors,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Generic card with text lines ───────────────────────────────────────────
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({
    required this.metrics,
    required this.colors,
    required this.lineCount,
  });

  final OrderDetailMetrics metrics;
  final AppThemeColors colors;
  final int lineCount;

  @override
  Widget build(BuildContext context) {
    return _Card(
      metrics: metrics,
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int index = 0; index < lineCount; index++) ...[
            if (index > 0) SizedBox(height: metrics.sectionGap * 0.4),
            _Block(
              width: index == lineCount - 1
                  ? metrics.pagePadding * 8
                  : double.infinity,
              height: metrics.pagePadding * 0.9,
              colors: colors,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Shared bits ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.metrics, required this.colors});

  final OrderDetailMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
      child: _Block(
        width: metrics.pagePadding * 7,
        height: metrics.pagePadding * 1.1,
        colors: colors,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.metrics,
    required this.colors,
    required this.child,
  });

  final OrderDetailMetrics metrics;
  final AppThemeColors colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(metrics.pagePadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: child,
      ),
    );
  }
}

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