import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/widgets/app_shimmer.dart';

/// Loading skeleton for the Auction Details screen — mirrors the hero
/// card + thumbnail strip, the Current Bid panel, Bid activity rows, the
/// Auction details grid, and the About this lot card.
class AuctionDetailShimmer extends StatelessWidget {
  const AuctionDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(4.1.w, 0.95.h, 4.1.w, 5.92.h),
        children: [
          // Hero card
          _Block(
            width: double.infinity,
            height: 20.h,
            radius: 24,
            colors: colors,
          ),

          SizedBox(height: 1.42.h),

          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) SizedBox(width: 2.05.w),
                _Block(width: 15.5.w, height: 15.5.w, radius: 12, colors: colors),
              ],
            ],
          ),

          SizedBox(height: 2.84.h),

          // Current Bid panel
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.62.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.border),
            ),
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
                          _Block(width: 22.w, height: 11, colors: colors),
                          SizedBox(height: 0.83.h),
                          _Block(width: 32.w, height: 25, colors: colors),
                          SizedBox(height: 0.6.h),
                          _Block(width: 26.w, height: 11, colors: colors),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Block(width: 26.w, height: 11, colors: colors),
                        SizedBox(height: 0.95.h),
                        Row(
                          children: [
                            for (var i = 0; i < 4; i++) ...[
                              if (i > 0) SizedBox(width: 0.9.w),
                              _Block(width: 9.w, height: 5.h, radius: 8, colors: colors),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 2.37.h),

                _Block(
                  width: double.infinity,
                  height: 8.h,
                  radius: 14,
                  colors: colors,
                ),

                SizedBox(height: 1.9.h),

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
              ],
            ),
          ),

          SizedBox(height: 3.32.h),

          // Bid activity
          _SectionTitleSkeleton(colors: colors),

          SizedBox(height: 1.42.h),

          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (var i = 0; i < 3; i++) _BidRowSkeleton(colors: colors),
              ],
            ),
          ),

          SizedBox(height: 3.32.h),

          // Auction details grid
          _SectionTitleSkeleton(colors: colors),

          SizedBox(height: 1.42.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(2.56.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 1.79.w,
                mainAxisSpacing: 0.83.h,
                childAspectRatio: 2.15,
              ),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.56.w, vertical: 1.07.h),
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      _Block(width: 7.69.w, height: 7.69.w, radius: 9, colors: colors),
                      SizedBox(width: 2.05.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Block(width: double.infinity, height: 10, colors: colors),
                            SizedBox(height: 0.6.h),
                            _Block(width: 14.w, height: 12, colors: colors),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 3.32.h),

          // About this lot
          _SectionTitleSkeleton(colors: colors),

          SizedBox(height: 1.42.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.62.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Block(width: 46.w, height: 16, colors: colors),
                SizedBox(height: 1.18.h),
                _Block(width: double.infinity, height: 13, colors: colors),
                SizedBox(height: 0.71.h),
                _Block(width: double.infinity, height: 13, colors: colors),
                SizedBox(height: 0.71.h),
                _Block(width: 60.w, height: 13, colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitleSkeleton extends StatelessWidget {
  const _SectionTitleSkeleton({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Block(width: 8.72.w, height: 8.72.w, radius: 10, colors: colors),
        SizedBox(width: 2.56.w),
        _Block(width: 34.w, height: 17, colors: colors),
      ],
    );
  }
}

class _BidRowSkeleton extends StatelessWidget {
  const _BidRowSkeleton({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.1.w, 1.54.h, 4.1.w, 1.54.h),
      child: Row(
        children: [
          _Block(width: 10.26.w, height: 10.26.w, radius: 20, colors: colors),
          SizedBox(width: 2.82.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Block(width: 32.w, height: 13, colors: colors),
                SizedBox(height: 0.6.h),
                _Block(width: 24.w, height: 11, colors: colors),
              ],
            ),
          ),
          SizedBox(width: 2.56.w),
          _Block(width: 16.w, height: 14, colors: colors),
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
