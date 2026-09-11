import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/shimmer_loading.dart';


class ServiceDetailShimmer extends StatelessWidget {
  const ServiceDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ShimmerBox(
              width: double.infinity,
              height: 25.h,
              borderRadius: BorderRadius.circular(12),
            ),
            SizedBox(height: 2.h),

            // Title
            ShimmerBox(width: 60.w, height: 20.sp),
            SizedBox(height: 1.2.h),

            // Vendor + category
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(width: double.infinity, height: 14.sp),
                ),
                SizedBox(width: 2.w),
                ShimmerBox(
                  width: 18.w,
                  height: 3.h,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
            SizedBox(height: 1.2.h),

            // Address
            ShimmerBox(width: 45.w, height: 13.sp),
            SizedBox(height: 1.5.h),

            // Rating + duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 30.w, height: 14.sp),
                ShimmerBox(width: 14.w, height: 14.sp),
              ],
            ),
            SizedBox(height: 1.5.h),

            // Map block
            ShimmerBox(
              width: double.infinity,
              height: 25.h,
              borderRadius: BorderRadius.circular(20),
            ),
            SizedBox(height: 3.h),

            // About
            ShimmerBox(width: 24.w, height: 16.sp),
            SizedBox(height: 1.h),
            ShimmerBox(width: double.infinity, height: 13.sp),
            SizedBox(height: 0.6.h),
            ShimmerBox(width: double.infinity, height: 13.sp),
            SizedBox(height: 0.6.h),
            ShimmerBox(width: 70.w, height: 13.sp),
            SizedBox(height: 2.h),

            // Offerings header
            ShimmerBox(width: 40.w, height: 16.sp),
            SizedBox(height: 1.h),

            // Offering rows
            for (var i = 0; i < 2; i++) ...[
              const _OfferingRowSkeleton(),
              SizedBox(height: 1.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _OfferingRowSkeleton extends StatelessWidget {
  const _OfferingRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 35.w, height: 14.sp),
                SizedBox(height: 0.6.h),
                ShimmerBox(width: 25.w, height: 13.sp),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 16.w, height: 15.sp),
              SizedBox(height: 0.6.h),
              ShimmerBox(width: 12.w, height: 13.sp),
            ],
          ),
        ],
      ),
    );
  }
}
