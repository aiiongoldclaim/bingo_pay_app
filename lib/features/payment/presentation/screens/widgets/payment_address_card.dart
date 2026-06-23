import 'package:flutter/material.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';

class PaymentAddressCard extends StatelessWidget {
  const PaymentAddressCard({
    super.key,
    required this.addressType,
    required this.address,
    required this.onChange,
  });

  final String addressType;
  final String address;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: ThemeColors.blue.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: ThemeColors.blue,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(addressType, style: AppTextStyles.titleMedium),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.blue.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Default',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: ThemeColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(address, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),

          GestureDetector(
            onTap: onChange,
            child: Text(
              'Change',
              style: AppTextStyles.labelLarge.copyWith(color: ThemeColors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
