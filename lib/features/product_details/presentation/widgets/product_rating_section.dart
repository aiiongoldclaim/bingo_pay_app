import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/product_details_model.dart';

/// Ratings & reviews summary: aggregate score + bar breakdown.
class ProductRatingsSection extends StatelessWidget {
  final String rating;
  final String reviewCount;
  final List<RatingBreakdown> breakdown;
  final VoidCallback? onSeeAll;

  const ProductRatingsSection({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.breakdown,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      color: ThemeColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ratings & reviews',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: ThemeColors.blue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Big score + star row + review count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rating,
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.ink,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star,
                        color: i < double.parse(rating).floor()
                            ? ThemeColors.accent
                            : ThemeColors.line,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  //SizedBox(height: 0.5.h),
                  Text(
                    reviewCount,
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: ThemeColors.inkDim,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 6.w),
              // Bar breakdown
              Expanded(
                child: Column(
                  children: breakdown
                      .map(
                        (b) =>
                            RatingBar(stars: b.stars, percentage: b.percentage),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RatingBar extends StatelessWidget {
  final int stars;
  final double percentage;

  const RatingBar({super.key, required this.stars, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.6.h),
      child: Row(
        children: [
          SizedBox(
            width: 2.w,
            child: Text(
              '$stars',
              style: TextStyle(fontSize: 15.sp, color: ThemeColors.inkDim),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: ThemeColors.line,
                valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.accent),
                minHeight: 0.8.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
