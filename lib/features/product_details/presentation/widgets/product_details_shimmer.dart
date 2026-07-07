import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/widgets/shimmer_loading.dart';

/// Skeleton placeholder shown while [ProductDetailScreen] loads, mirroring
/// its layout (image, info, colors, policies, highlights, ratings, bottom bar).
class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBox(
                          width: 10.w,
                          height: 10.w,
                          borderRadius: BorderRadius.circular(10.w),
                        ),
                        Row(
                          children: [
                            ShimmerBox(
                              width: 10.w,
                              height: 10.w,
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            SizedBox(width: 2.w),
                            ShimmerBox(
                              width: 10.w,
                              height: 10.w,
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Product image
                  Padding(
                    padding: EdgeInsets.all(5.w),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 30.h,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Info section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerBox(width: 24.w, height: 14),
                            ShimmerBox(
                              width: 18.w,
                              height: 20,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.2.h),
                        ShimmerBox(width: 60.w, height: 20),
                        SizedBox(height: 1.2.h),
                        Row(
                          children: [
                            ShimmerBox(width: 20.w, height: 20),
                            SizedBox(width: 2.w),
                            ShimmerBox(width: 14.w, height: 14),
                            SizedBox(width: 2.w),
                            ShimmerBox(
                              width: 16.w,
                              height: 18,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Color section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 26.w, height: 15),
                          SizedBox(height: 1.5.h),
                          Row(
                            children: List.generate(
                              4,
                              (_) => Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ShimmerBox(
                                  width: 56,
                                  height: 56,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Policies section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 8.h,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Highlights section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 32.w, height: 15),
                        SizedBox(height: 1.5.h),
                        ...List.generate(
                          3,
                          (_) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ShimmerBox(
                              width: double.infinity,
                              height: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Ratings section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 16.h,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Row(
              children: [
                Expanded(
                  child: ShimmerBox(
                    height: 6.h,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ShimmerBox(
                    height: 6.h,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
