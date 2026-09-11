import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/widgets/app_shimmer.dart';

/// Loading skeleton for the Auctions list screen — mirrors the hero card,
/// the two CTA buttons, and a few "Live Auctions" row cards.
class AuctionListShimmer extends StatelessWidget {
  const AuctionListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(4.1.w, 1.42.h, 4.1.w, 3.55.h),
        children: [
          _Block(
            width: double.infinity,
            height: 24.h,
            radius: 24,
            colors: colors,
          ),

          SizedBox(height: 1.66.h),

          _Block(
            width: double.infinity,
            height: 6.16.h,
            radius: 14,
            colors: colors,
          ),

          SizedBox(height: 1.42.h),

          _Block(
            width: double.infinity,
            height: 6.16.h,
            radius: 14,
            colors: colors,
          ),

          SizedBox(height: 2.84.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Block(width: 32.w, height: 20, colors: colors),
              _Block(width: 16.w, height: 14, colors: colors),
            ],
          ),

          SizedBox(height: 1.9.h),

          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(height: 1.42.h),
            _RowCardSkeleton(colors: colors),
          ],
        ],
      ),
    );
  }
}

class _RowCardSkeleton extends StatelessWidget {
  const _RowCardSkeleton({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.05.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Block(
            width: 20.51.w,
            height: 20.51.w,
            radius: 14,
            colors: colors,
          ),

          SizedBox(width: 2.82.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Block(width: double.infinity, height: 15, colors: colors),
                SizedBox(height: 0.83.h),
                _Block(width: 30.w, height: 12, colors: colors),
                SizedBox(height: 1.42.h),
                _Block(width: 24.w, height: 11, colors: colors),
                SizedBox(height: 0.47.h),
                _Block(width: 26.w, height: 18, colors: colors),
                SizedBox(height: 0.83.h),
                _Block(width: 40.w, height: 11, colors: colors),
              ],
            ),
          ),

          SizedBox(width: 1.03.w),

          _Block(
            width: 7.69.w,
            height: 7.69.w,
            radius: 20,
            colors: colors,
          ),
        ],
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
