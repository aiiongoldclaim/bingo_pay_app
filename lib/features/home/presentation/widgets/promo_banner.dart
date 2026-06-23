import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.title,
    required this.heading,
    required this.buttonText,
    this.onTap,
    this.icon = Icons.card_giftcard_rounded,
  });

  final String title;
  final String heading;
  final String buttonText;
  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      height: 22.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ThemeColors.accent,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Stack(
        children: [
          /// Background Gift Icon
          Positioned(
            right: -2.w,
            bottom: -2.h,
            child: Icon(
              icon,
              size: 28.w,
              color: ThemeColors.white.withOpacity(.25),
            ),
          ),

          /// Content
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingLg.toDouble()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTextStyles.bannerTitle.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 0.8.h),

                Expanded(
                  child: Text(
                    heading,
                    style: AppTextStyles.bannerHeading.copyWith(
                      fontSize: 20.sp,
                      color: ThemeColors.accentInk,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.4.h,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.accentInk,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: 15.sp,
                            color: ThemeColors.white,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: ThemeColors.white,
                          size: AppSizes.iconMd,
                        ),
                      ],
                    ),
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
