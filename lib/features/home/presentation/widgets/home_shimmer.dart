// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/widgets/shimmer_loading.dart';
//
// /// Skeleton placeholder shown while [HomeScreen] loads, mirroring its
// /// layout (header, wallet card, search bar, categories, product rows).
// class HomeShimmer extends StatelessWidget {
//   const HomeShimmer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoading(
//       child: SingleChildScrollView(
//         physics: const NeverScrollableScrollPhysics(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(
//                 left: 5.w,
//                 right: 5.w,
//                 top: 6.h,
//                 bottom: 2.h,
//               ),
//               child: Row(
//                 children: [
//                   ShimmerBox(
//                     width: 13.w,
//                     height: 13.w,
//                     borderRadius: BorderRadius.circular(13.w),
//                   ),
//                   SizedBox(width: 3.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ShimmerBox(width: 30.w, height: 10),
//                         SizedBox(height: 1.h),
//                         ShimmerBox(width: 40.w, height: 14),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 3.w),
//                   ShimmerBox(
//                     width: 9.w,
//                     height: 9.w,
//                     borderRadius: BorderRadius.circular(9.w),
//                   ),
//                 ],
//               ),
//             ),
//
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 5.w),
//               child: ShimmerBox(
//                 height: 8.h,
//                 width: double.infinity,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//
//             SizedBox(height: 2.h),
//
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 5.w),
//               child: ShimmerBox(
//                 height: 6.h,
//                 width: double.infinity,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//
//             SizedBox(height: 3.h),
//
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 5.w),
//               child: ShimmerBox(width: 40.w, height: 16),
//             ),
//
//             SizedBox(height: 1.h),
//
//             SizedBox(
//               height: 15.h,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(horizontal: 4.w),
//                 itemCount: 5,
//                 itemBuilder: (_, _) => Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 1.w),
//                   child: Column(
//                     children: [
//                       ShimmerBox(
//                         width: 18.w,
//                         height: 18.w,
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       SizedBox(height: 1.h),
//                       ShimmerBox(width: 14.w, height: 10),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 2.h),
//
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 5.w),
//               child: ShimmerBox(width: 34.w, height: 16),
//             ),
//
//             SizedBox(height: 1.h),
//
//             SizedBox(
//               height: 34.h,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(horizontal: 4.w),
//                 itemCount: 3,
//                 itemBuilder: (_, _) => Padding(
//                   padding: EdgeInsets.only(right: 3.w),
//                   child: SizedBox(
//                     width: 42.w,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ShimmerBox(
//                           width: 42.w,
//                           height: 22.h,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         SizedBox(height: 1.h),
//                         ShimmerBox(width: 30.w, height: 10),
//                         SizedBox(height: 0.6.h),
//                         ShimmerBox(width: 24.w, height: 12),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 2.h),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../../core/widgets/shimmer_loading.dart';
import 'home_metrics.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final m = HomeMetrics.of(context);

    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
                  child: SizedBox(
                    height: m.headerHeight,
                    child: Row(
                      children: [
                        ShimmerBox(
                          width: m.headerIconSize,
                          height: m.headerIconSize,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const Spacer(),
                        ShimmerBox(width: m.logoSize * 4, height: m.logoSize),
                        const Spacer(),
                        ShimmerBox(
                          width: m.headerIconSize,
                          height: m.headerIconSize,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        SizedBox(width: m.pagePadding * 0.9),
                        ShimmerBox(
                          width: m.headerIconSize,
                          height: m.headerIconSize,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: m.pagePadding * 0.75),

                // Search
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: m.searchHeight,
                    borderRadius: BorderRadius.circular(m.searchRadius),
                  ),
                ),

                SizedBox(height: m.pagePadding * 0.8),

                // Tabs
                SizedBox(
                  height: m.tabBarHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
                    itemCount: 6,
                    separatorBuilder: (_, __) => SizedBox(width: m.tabGap),
                    itemBuilder: (_, __) => Center(
                      child: ShimmerBox(
                        width: m.tabFontSize * 4,
                        height: m.tabFontSize,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: m.sectionGap),

                // Hero banner
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: m.heroHeight,
                    borderRadius: BorderRadius.circular(m.heroRadius),
                  ),
                ),

                SizedBox(height: m.sectionGap),

                // Categories
                SizedBox(
                  height: m.categoryRowHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
                    itemCount: 7,
                    separatorBuilder: (_, __) =>
                        SizedBox(width: m.pagePadding * 0.7),
                    itemBuilder: (_, __) => Column(
                      children: [
                        ShimmerBox(
                          width: m.categoryCircle,
                          height: m.categoryCircle,
                          borderRadius: BorderRadius.circular(m.categoryCircle),
                        ),
                        SizedBox(height: m.pagePadding * 0.45),
                        ShimmerBox(
                          width: m.categoryCircle * 0.7,
                          height: m.categoryLabelSize,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: m.sectionGap),

                // Book services
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: m.serviceTileSize + m.pagePadding * 2,
                    borderRadius: BorderRadius.circular(m.heroRadius * 0.75),
                  ),
                ),

                SizedBox(height: m.sectionGap),

                // Product rail
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
                  child: ShimmerBox(
                    width: m.productCardWidth,
                    height: m.sectionTitleSize,
                  ),
                ),
                SizedBox(height: m.pagePadding * 0.8),
                SizedBox(
                  height: m.productCardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
                    itemCount: 4,
                    separatorBuilder: (_, __) =>
                        SizedBox(width: m.pagePadding * 0.7),
                    itemBuilder: (_, __) => SizedBox(
                      width: m.productCardWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(
                            width: m.productCardWidth,
                            height: m.productImageHeight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          SizedBox(height: m.pagePadding * 0.5),
                          ShimmerBox(
                            width: m.productCardWidth * 0.6,
                            height: m.productBrandSize,
                          ),
                          SizedBox(height: m.pagePadding * 0.3),
                          ShimmerBox(
                            width: m.productCardWidth * 0.85,
                            height: m.productNameSize,
                          ),
                          SizedBox(height: m.pagePadding * 0.3),
                          ShimmerBox(
                            width: m.productCardWidth * 0.5,
                            height: m.productPriceSize,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: m.sectionGap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
