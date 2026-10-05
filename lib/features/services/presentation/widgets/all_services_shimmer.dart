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
      // Sized from the cell's own constraints so the skeleton fits both the
      // full-width grid and the narrow split-view pane without overflowing.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth;
          final cellHeight = constraints.maxHeight;
          final padding = cellWidth * 0.07;
          final contentHeight = cellHeight * 0.45 - padding * 2;
          final lineHeight = (contentHeight / 6).clamp(4.0, 13.sp).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
              ),
              SizedBox(
                height: cellHeight * 0.45,
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: double.infinity, height: lineHeight),
                      ShimmerBox(width: cellWidth * 0.6, height: lineHeight),
                      ShimmerBox(width: cellWidth * 0.4, height: lineHeight),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerBox(
                            width: cellWidth * 0.35,
                            height: lineHeight,
                          ),
                          ShimmerBox(
                            width: cellWidth * 0.25,
                            height: lineHeight * 1.6,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
