import 'package:bingo_pay/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';

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
        color: ThemeColors.white.withOpacity(.25),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ThemeColors.white,
                  ),
                ),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "₹${amount.toStringAsFixed(0)} ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: ThemeColors.white,
                        ),
                      ),
                      TextSpan(
                        text: goldWeight,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ThemeColors.white,
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
            child: AppButton(
              label: 'Top up',
              textColor: ThemeColors.blue,
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
