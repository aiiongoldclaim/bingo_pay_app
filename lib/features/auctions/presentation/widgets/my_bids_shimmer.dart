import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/widgets/app_shimmer.dart';

/// Loading skeleton for the My Bids screen — mirrors the subtitle, the
/// four summary cards, the filter chips, and a few bid cards.
class MyBidsShimmer extends StatelessWidget {
  const MyBidsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(4.1.w, 1.42.h, 4.1.w, 3.8.h),
        children: [
          _Block(width: 70.w, height: 12, colors: colors),

          SizedBox(height: 2.13.h),

          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) SizedBox(width: 2.05.w),
                Expanded(
                  child: _Block(
                    width: double.infinity,
                    height: 13.h,
                    radius: 16,
                    colors: colors,
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 2.6.h),

          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) SizedBox(width: 2.05.w),
                _Block(
                  width: i == 0 ? 16.w : 22.w,
                  height: 3.6.h,
                  radius: 22,
                  colors: colors,
                ),
              ],
            ],
          ),

          SizedBox(height: 2.13.h),

          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(height: 1.9.h),
            _BidCardSkeleton(colors: colors),
          ],
        ],
      ),
    );
  }
}

class _BidCardSkeleton extends StatelessWidget {
  const _BidCardSkeleton({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Block(width: 28.2.w, height: double.infinity, radius: 0, colors: colors),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Block(width: double.infinity, height: 16, colors: colors),
                              SizedBox(height: 0.6.h),
                              _Block(width: 26.w, height: 11, colors: colors),
                            ],
                          ),
                        ),
                        SizedBox(width: 1.28.w),
                        _Block(width: 18.w, height: 20, radius: 18, colors: colors),
                      ],
                    ),

                    SizedBox(height: 0.83.h),

                    _Block(width: 34.w, height: 12, colors: colors),

                    SizedBox(height: 1.42.h),

                    Container(height: 1, color: colors.border),

                    SizedBox(height: 1.18.h),

                    Row(
                      children: [
                        for (var i = 0; i < 3; i++) ...[
                          if (i > 0) SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Block(width: 16.w, height: 11, colors: colors),
                                SizedBox(height: 0.36.h),
                                _Block(width: 12.w, height: 14, colors: colors),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 1.42.h),

                    Row(
                      children: [
                        Expanded(
                          child: _Block(width: double.infinity, height: 12, colors: colors),
                        ),
                        SizedBox(width: 1.79.w),
                        _Block(width: 22.w, height: 4.2.h, radius: 10, colors: colors),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
