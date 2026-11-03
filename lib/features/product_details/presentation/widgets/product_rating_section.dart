// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../../core/theme/theme_colors.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../data/models/product_details_model.dart';
//
// /// Ratings & reviews summary: aggregate score + bar breakdown.
// class ProductRatingsSection extends StatelessWidget {
//   final String rating;
//   final String reviewCount;
//   final List<RatingBreakdown> breakdown;
//   final VoidCallback? onSeeAll;
//
//   const ProductRatingsSection({
//     super.key,
//     required this.rating,
//     required this.reviewCount,
//     required this.breakdown,
//     this.onSeeAll,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(4.w),
//       color: ThemeColors.surface,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Text(
//             'Ratings & reviews',
//             style: AppTextStyles.titleLarge.copyWith(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.w700,
//               color: ThemeColors.black,
//             ),
//           ),
//           SizedBox(height: 1.h),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Big score + star row + review count
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     rating,
//                     style: TextStyle(
//                       fontSize: 36.sp,
//                       fontWeight: FontWeight.w700,
//                       color: ThemeColors.ink,
//                     ),
//                   ),
//                   Row(
//                     children: List.generate(
//                       5,
//                       (i) => Icon(
//                         Icons.star,
//                         color: i < double.parse(rating).floor()
//                             ? ThemeColors.accent
//                             : ThemeColors.line,
//                         size: 17.sp,
//                       ),
//                     ),
//                   ),
//
//                   Text(
//                     reviewCount,
//                     style: TextStyle(
//                       fontSize: 17.sp,
//                       color: ThemeColors.inkDim,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(width: 6.w),
//               // Bar breakdown
//               Expanded(
//                 child: Column(
//                   children: breakdown
//                       .map(
//                         (b) =>
//                             RatingBar(stars: b.stars, percentage: b.percentage),
//                       )
//                       .toList(),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class RatingBar extends StatelessWidget {
//   final int stars;
//   final double percentage;
//
//   const RatingBar({super.key, required this.stars, required this.percentage});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 0.6.h),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 2.w,
//             child: Text(
//               '$stars',
//               style: TextStyle(fontSize: 15.sp, color: ThemeColors.inkDim),
//             ),
//           ),
//           SizedBox(width: 2.w),
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: percentage,
//                 backgroundColor: ThemeColors.line,
//                 valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.accent),
//                 minHeight: 0.8.h,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:bingo_pay/features/product_details/presentation/widgets/product_detail_widgets.dart';
import 'package:bingo_pay/features/product_details/presentation/widgets/product_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../reviews/presentation/cubit/reviews_cubits.dart';
import '../../../reviews/presentation/widgets/review_widgets.dart';

/// Rating summary, star breakdown and approved reviews of the product.
/// Shows the rating the product came with until (or if) the reviews load.
class ProductRatingsBlock extends StatelessWidget {
  final ProductMetrics metrics;
  final String rating;
  final String reviewCount;
  final String? productUuid;

  const ProductRatingsBlock({
    super.key,
    required this.metrics,
    required this.rating,
    required this.reviewCount,
    this.productUuid,
  });

  @override
  Widget build(BuildContext context) {
    final uuid = productUuid;
    if (uuid == null || uuid.isEmpty) {
      return _content(context, const ProductReviewsState(failed: true));
    }
    return BlocProvider(
      create: (_) => getIt<ProductReviewsCubit>()..load(uuid),
      child: BlocBuilder<ProductReviewsCubit, ProductReviewsState>(
        builder: _content,
      ),
    );
  }

  Widget _content(BuildContext context, ProductReviewsState state) {
    final colors = context.c;
    final m = metrics;
    final summary = state.summary;
    final average = summary == null
        ? rating
        : summary.averageRating?.toStringAsFixed(1) ?? '–';
    final count = summary == null ? reviewCount : '${summary.totalReviews}';
    final muted = AppTextStyles.bodyMedium.copyWith(
      color: colors.textSecondary,
      fontFamily: 'Inter',
      fontSize: m.rowSubSize + 1,
    );

    return ProductSectionCard(
      metrics: m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.ratingsReviews,
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.sectionTitleSize,
            ),
          ),

          SizedBox(height: m.gapMd),

          Row(
            children: [
              Icon(Icons.star_rounded, size: m.priceSize, color: colors.brand),
              SizedBox(width: m.gapSm * 0.7),
              Text(
                average,
                style: AppTextStyles.titleLarge.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.priceSize * 0.8,
                ),
              ),
              SizedBox(width: m.gapSm),
              Text(
                AppStrings.ratingsCount(count),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.rowSubSize + 3,
                ),
              ),
            ],
          ),

          if (summary != null && summary.totalReviews == 0) ...[
            SizedBox(height: m.gapSm),
            Text('No reviews yet.', style: muted),
          ],

          if (summary != null && summary.totalReviews > 0) ...[
            SizedBox(height: m.gapMd),
            for (var stars = 5; stars >= 1; stars--)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(width: 16, child: Text('$stars', style: muted)),
                    Icon(Icons.star_rounded, size: 14, color: colors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value:
                              (summary.distribution[stars] ?? 0) /
                              summary.totalReviews,
                          minHeight: 6,
                          backgroundColor: colors.border,
                          valueColor: AlwaysStoppedAnimation(colors.brand),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${summary.distribution[stars] ?? 0}',
                        textAlign: TextAlign.end,
                        style: muted,
                      ),
                    ),
                  ],
                ),
              ),
          ],

          for (final review in state.reviews) ...[
            Divider(height: m.gapMd * 2, color: colors.border),
            ReviewTile(review: review),
          ],

          if (state.hasMore)
            Center(
              child: state.loadingMore
                  ? Padding(
                      padding: EdgeInsets.all(m.gapSm),
                      child: CircularProgressIndicator(color: colors.brand),
                    )
                  : TextButton(
                      onPressed: context.read<ProductReviewsCubit>().loadMore,
                      child: const Text('Show more reviews'),
                    ),
            ),
        ],
      ),
    );
  }
}
