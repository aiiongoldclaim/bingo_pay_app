import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/shimmer_loading.dart';


class AllServicesShimmer extends StatelessWidget {
  const AllServicesShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 0.78,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => _ServiceCardSkeleton(colors: colors),
      ),
    );
  }
}

class _ServiceCardSkeleton extends StatelessWidget {
  const _ServiceCardSkeleton({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: double.infinity,
            height: 13.h,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 13.sp),
                SizedBox(height: 0.6.h),
                ShimmerBox(width: 24.w, height: 13.sp),
                SizedBox(height: 1.h),
                ShimmerBox(width: 16.w, height: 12.sp),
                SizedBox(height: 1.2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 14.w, height: 14.sp),
                    ShimmerBox(
                      width: 10.w,
                      height: 4.h,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
