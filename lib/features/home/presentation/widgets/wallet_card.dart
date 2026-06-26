import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({super.key, required this.bigoldBalance});

  final String bigoldBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: ThemeColors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Gold coin icon
          Container(
            width: 11.w,
            height: 11.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.toll_rounded,
              color: const Color(0xFFFFD700),
              size: 20.sp,
            ),
          ),

          SizedBox(width: 3.w),

          // Label + balance
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bingold Wallet',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: ThemeColors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  bigoldBalance,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: ThemeColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),

          // Arrow indicator
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ThemeColors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: ThemeColors.white,
              size: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
