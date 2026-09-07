import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import 'cart_metrics.dart';

/// Loading placeholder for the Cart screen, shown while loadCart() is in
/// flight — mirrors the loaded layout (title block, delivery banner, item
/// rows, price summary) instead of a bare spinner.
class CartShimmer extends StatelessWidget {
  const CartShimmer({super.key, required this.metrics});

  final CartMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return AppShimmer(
      backgroundColor: colors.background,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapXs, m.pageHPad, m.gapLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title block: "My Cart (N)" + subtitle
            _Block(width: 40.w, height: m.pageTitleSize + 6, colors: colors),
            SizedBox(height: m.gapXs),
            _Block(width: 55.w, height: m.pageSubtitleSize + 4, colors: colors),

            SizedBox(height: m.gapMd),

            // Delivery banner
            Container(
              height: m.bannerIconBox + m.bannerPad,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(m.bannerRadius),
                border: Border.all(color: colors.border),
              ),
            ),

            SizedBox(height: m.gapMd),

            // Item rows
            for (var i = 0; i < 3; i++) ...[
              _ItemRowSkeleton(metrics: m, colors: colors),
              if (i < 2) SizedBox(height: m.gapMd),
            ],

            SizedBox(height: m.gapMd),

            // Coupon card
            Container(
              height: m.bannerIconBox * 0.85 + m.cardPad,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(m.cardRadius),
                border: Border.all(color: colors.border),
              ),
            ),

            SizedBox(height: m.gapMd),

            // Price summary card
            Container(
              padding: EdgeInsets.all(m.cardPad),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(m.cardRadius),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Block(width: 30.w, height: m.summaryTitleSize + 2, colors: colors),
                  SizedBox(height: m.gapMd),
                  _SummaryRowSkeleton(colors: colors),
                  SizedBox(height: m.gapSm),
                  _SummaryRowSkeleton(colors: colors),
                  SizedBox(height: m.gapSm),
                  _SummaryRowSkeleton(colors: colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRowSkeleton extends StatelessWidget {
  const _ItemRowSkeleton({required this.metrics, required this.colors});

  final CartMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    return Container(
      height: m.thumbSize,
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: m.thumbSize * 0.65,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(m.thumbRadius),
            ),
          ),
          SizedBox(width: m.cardPad),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Block(width: 60.w, height: m.brandSize, colors: colors),
                SizedBox(height: m.gapXs),
                _Block(width: 40.w, height: m.titleSize, colors: colors),
                SizedBox(height: m.gapSm),
                _Block(width: 20.w, height: m.priceSize, colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRowSkeleton extends StatelessWidget {
  const _SummaryRowSkeleton({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Block(width: 90, height: 14, colors: colors),
        _Block(width: 50, height: 14, colors: colors),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.width,
    required this.height,
    required this.colors,
  });

  final double width;
  final double height;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
