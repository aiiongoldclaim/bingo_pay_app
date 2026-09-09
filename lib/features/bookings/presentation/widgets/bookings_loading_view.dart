import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';

class BookingsLoadingView extends StatelessWidget {
  const BookingsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(5.13.w, 1.66.h, 5.13.w, 1.66.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookingSkeleton(width: 33.33.w, height: 2.13.h),
                SizedBox(height: 0.71.h),
                BookingSkeleton(width: 51.28.w, height: 1.42.h),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.1.w, 0, 4.1.w, 1.66.h),
            child: Row(
              children: [
                BookingSkeleton(width: 16.92.w, height: 4.03.h),
                SizedBox(width: 2.31.w),
                BookingSkeleton(width: 24.62.w, height: 4.03.h),
                SizedBox(width: 2.31.w),
                BookingSkeleton(width: 26.67.w, height: 4.03.h),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 4.1.w),
          sliver: SliverList.separated(
            itemCount: 4,
            separatorBuilder: (_, __) => SizedBox(height: 1.66.h),
            itemBuilder: (_, __) {
              return Container(
                height: 23.22.h,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colors.border),
                ),
                padding: EdgeInsets.all(3.59.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookingSkeleton(width: 18.97.w, height: 10.9.h),
                        SizedBox(width: 3.33.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BookingSkeleton(height: 1.9.h),
                              SizedBox(height: 0.95.h),
                              BookingSkeleton(width: 30.77.w, height: 1.42.h),
                              SizedBox(height: 1.66.h),
                              BookingSkeleton(height: 1.42.h),
                              SizedBox(height: 0.95.h),
                              BookingSkeleton(width: 35.9.w, height: 1.42.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.9.h),
                    BookingSkeleton(height: 4.98.h),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class BookingSkeleton extends StatelessWidget {
  const BookingSkeleton({super.key, this.width = double.infinity, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.border.withValues(alpha: colors.isDark ? 0.35 : 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
