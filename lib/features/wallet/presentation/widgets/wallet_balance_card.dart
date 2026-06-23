import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.walletName,
    required this.balance,
    required this.subTitle,
    required this.onAddMoney,
    required this.onSend,
  });

  final String walletName;
  final String balance;
  final String subTitle;
  final VoidCallback onAddMoney;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: ThemeColors.primaryGradient,
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Wallet Name
          Row(
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: ThemeColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'B',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: ThemeColors.ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                walletName,
                style: AppTextStyles.titleMedium.copyWith(
                  color: ThemeColors.white,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.5.h),

          /// Balance
          Text(
            balance,
            style: AppTextStyles.displayLarge.copyWith(
              color: ThemeColors.white,
              fontSize: 24.sp,
            ),
          ),

          SizedBox(height: 0.8.h),

          /// Subtitle
          Text(
            subTitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: ThemeColors.white.withOpacity(0.8),
            ),
          ),

          SizedBox(height: 3.h),

          /// Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Add Money',
                  prefixIcon: Icons.add,
                  variant: AppButtonVariant.secondary,
                  onPressed: onAddMoney,
                ),
              ),

              SizedBox(width: 3.w),

              Expanded(
                child: AppButton(
                  label: 'Send',
                  prefixIcon: Icons.arrow_forward,
                  variant: AppButtonVariant.primary,
                  onPressed: onSend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
