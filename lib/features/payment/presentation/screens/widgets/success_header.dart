import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';

class SuccessHeader extends StatelessWidget {
  final String orderId;
  final String amount;

  const SuccessHeader({super.key, required this.orderId, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXl),
      child: Column(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeColors.white,
            ),
            child: const Icon(Icons.check, size: 50, color: ThemeColors.green),
          ),

          const SizedBox(height: 24),

          Text(
            'Payment successful',
            style: AppTextStyles.headlineMedium.copyWith(
              color: ThemeColors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Order #$orderId • $amount paid',
            style: AppTextStyles.bodyLarge.copyWith(color: ThemeColors.white),
          ),
        ],
      ),
    );
  }
}
