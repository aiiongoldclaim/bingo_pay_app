import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/widgets/shimmer_loading.dart';

/// Skeleton placeholder shown while [HomeScreen] loads, mirroring its
/// layout (header, wallet card, search bar, categories, product rows).
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 5.w,
                right: 5.w,
                top: 6.h,
                bottom: 2.h,
              ),
              child: Row(
                children: [
                  ShimmerBox(
                    width: 13.w,
                    height: 13.w,
                    borderRadius: BorderRadius.circular(13.w),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 30.w, height: 10),
                        SizedBox(height: 1.h),
                        ShimmerBox(width: 40.w, height: 14),
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  ShimmerBox(
                    width: 9.w,
                    height: 9.w,
                    borderRadius: BorderRadius.circular(9.w),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: ShimmerBox(
                height: 8.h,
                width: double.infinity,
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            SizedBox(height: 2.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: ShimmerBox(
                height: 6.h,
                width: double.infinity,
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            SizedBox(height: 3.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: ShimmerBox(width: 40.w, height: 16),
            ),

            SizedBox(height: 1.h),

            SizedBox(
              height: 15.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: 5,
                itemBuilder: (_, _) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Column(
                    children: [
                      ShimmerBox(
                        width: 18.w,
                        height: 18.w,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      SizedBox(height: 1.h),
                      ShimmerBox(width: 14.w, height: 10),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: ShimmerBox(width: 34.w, height: 16),
            ),

            SizedBox(height: 1.h),

            SizedBox(
              height: 34.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: 3,
                itemBuilder: (_, _) => Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: SizedBox(
                    width: 42.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(
                          width: 42.w,
                          height: 22.h,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        SizedBox(height: 1.h),
                        ShimmerBox(width: 30.w, height: 10),
                        SizedBox(height: 0.6.h),
                        ShimmerBox(width: 24.w, height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
