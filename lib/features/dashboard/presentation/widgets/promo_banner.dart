import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(5.w),
      height: 22.h,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(7.w),
      ),
      child: Stack(
        children: [
          /// Gift Icon
          Positioned(
            right: -4.w,
            bottom: -1.h,
            child: SvgPicture.asset(
              'assets/icons/gift.svg',
              width: 42.w,
              height: 42.w,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(.35),
                BlendMode.srcIn,
              ),
            ),
          ),

          /// Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FESTIVE GOLD DAYS',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: 'CormorantGaramond',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.accentInk,
                ),
              ),

              SizedBox(height: 1.h),

              Text(
                'Up to 60% Off\non everything',
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  height: 0.95,
                  color: AppColors.accentInk,
                ),
              ),

              const Spacer(),

              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 1.3.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B3404),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Shop the sale',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 16.sp,
                          fontFamily: 'CormorantGaramond',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(
                        Icons.arrow_forward,
                        size: 15.sp,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
