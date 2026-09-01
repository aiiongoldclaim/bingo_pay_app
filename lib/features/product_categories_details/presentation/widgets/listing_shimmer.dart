import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../product_categories_cubit/product_categories_state.dart';

class ListingShimmer extends StatelessWidget {
  const ListingShimmer({super.key, this.viewMode = ViewMode.grid});

  final ViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          // Results bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Block(width: 22.w, height: 2.h, colors: colors),
                  _Block(width: 16.w, height: 2.h, colors: colors),
                ],
              ),
            ),
          ),

          if (viewMode == ViewMode.grid)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _GridCardSkeleton(colors: colors),
                  childCount: 6,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: SizedBox(
                      height: 18.h,
                      child: _ListCardSkeleton(colors: colors),
                    ),
                  ),
                  childCount: 5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GridCardSkeleton extends StatelessWidget {
  const _GridCardSkeleton({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: colors.surfaceAlt,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 1.2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Block(width: 16.w, height: 1.2.h, colors: colors),
                SizedBox(height: 0.6.h),
                _Block(width: double.infinity, height: 1.4.h, colors: colors),
                SizedBox(height: 0.6.h),
                _Block(width: 12.w, height: 1.8.h, colors: colors),
                SizedBox(height: 0.8.h),
                _Block(width: 20.w, height: 1.8.h, colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCardSkeleton extends StatelessWidget {
  const _ListCardSkeleton({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(width: 36.w, color: colors.surfaceAlt),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Block(width: 16.w, height: 1.2.h, colors: colors),
                  SizedBox(height: 0.8.h),
                  _Block(width: double.infinity, height: 1.4.h, colors: colors),
                  SizedBox(height: 0.6.h),
                  _Block(width: 30.w, height: 1.4.h, colors: colors),
                  SizedBox(height: 1.h),
                  _Block(width: 12.w, height: 1.8.h, colors: colors),
                  SizedBox(height: 0.8.h),
                  _Block(width: 22.w, height: 2.h, colors: colors),
                ],
              ),
            ),
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