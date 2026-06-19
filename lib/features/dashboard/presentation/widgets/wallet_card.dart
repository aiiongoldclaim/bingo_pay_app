import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({super.key, required this.amount, required this.goldWeight});

  final double amount;
  final String goldWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white60,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 5.w,
              backgroundColor: AppColors.accent,
              child: Text(
                "B",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BINGO Wallet",
                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                ),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "₹${amount.toStringAsFixed(0)} ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      TextSpan(
                        text: goldWeight,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 25.w,
            height: 5.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Top up',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'CormorantGaramond',
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
