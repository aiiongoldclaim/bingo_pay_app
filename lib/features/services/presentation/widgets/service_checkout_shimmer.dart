import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class ServiceCheckoutShimmer extends StatelessWidget {
  const ServiceCheckoutShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress tracker
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ProgressStepSkeleton(),
                    _ProgressLineSkeleton(colors: colors),
                    const _ProgressStepSkeleton(),
                    _ProgressLineSkeleton(colors: colors),
                    const _ProgressStepSkeleton(),
                  ],
                ),
                SizedBox(height: 2.5.h),

                // "Almost there" intro
                Row(
                  children: [
                    ShimmerBox(
                      width: 42,
                      height: 42,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 35.w, height: 14.sp),
                          SizedBox(height: 0.5.h),
                          ShimmerBox(width: 60.w, height: 12.sp),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.2.h),

                // Order summary card
                Container(
                  padding: EdgeInsets.all(3.5.w),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShimmerBox(width: 30.w, height: 14.sp),
                          const Spacer(),
                          ShimmerBox(
                            width: 16.w,
                            height: 2.6.h,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.6.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(
                            width: 56,
                            height: 56,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerBox(width: 50.w, height: 14.sp),
                                SizedBox(height: 0.6.h),
                                ShimmerBox(width: 30.w, height: 12.sp),
                                SizedBox(height: 0.6.h),
                                ShimmerBox(width: 40.w, height: 12.sp),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.2.h),

                // Address section
                _SectionHeadingSkeleton(colors: colors),
                SizedBox(height: 1.1.h),
                Container(
                  padding: EdgeInsets.all(3.5.w),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: 45.w, height: 14.sp),
                            SizedBox(height: 0.6.h),
                            ShimmerBox(width: 70.w, height: 12.sp),
                          ],
                        ),
                      ),
                      ShimmerBox(
                        width: 22,
                        height: 22,
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.2.h),

                // Payment section
                _SectionHeadingSkeleton(colors: colors),
                SizedBox(height: 1.1.h),
                Container(
                  padding: EdgeInsets.all(3.5.w),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      ShimmerBox(
                        width: 48,
                        height: 48,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: 40.w, height: 14.sp),
                            SizedBox(height: 0.6.h),
                            ShimmerBox(width: 55.w, height: 12.sp),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeadingSkeleton extends StatelessWidget {
  const _SectionHeadingSkeleton({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerBox(
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(12),
        ),
        SizedBox(width: 2.7.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 35.w, height: 15.sp),
              SizedBox(height: 0.5.h),
              ShimmerBox(width: 55.w, height: 12.sp),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressStepSkeleton extends StatelessWidget {
  const _ProgressStepSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ShimmerBox(
          width: 30,
          height: 30,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        SizedBox(height: 0.7.h),
        ShimmerBox(width: 14.w, height: 11.sp),
      ],
    );
  }
}

class _ProgressLineSkeleton extends StatelessWidget {
  const _ProgressLineSkeleton({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 14.5),
        child: Container(
          height: 1,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          color: colors.border,
        ),
      ),
    );
  }
}
