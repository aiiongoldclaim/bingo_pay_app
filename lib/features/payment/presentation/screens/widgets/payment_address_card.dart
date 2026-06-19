import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';


class PaymentAddressCard extends StatelessWidget {
  const PaymentAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: ThemeColors.blue,
            size: 24.sp,
          ),
          SizedBox(width: AppDimensions.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Home',
                      style: AppTextStyles.titleMedium,
                    ),
                    SizedBox(width: AppDimensions.sm),
                    Text(
                      'Default',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: ThemeColors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.8.h),
                Text(
                  '14 Lotus Residency, Bandra West, Mumbai 400050',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: ThemeColors.blue,
              textStyle: AppTextStyles.labelLarge,
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}