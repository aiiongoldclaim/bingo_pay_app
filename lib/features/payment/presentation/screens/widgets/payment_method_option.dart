import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../cubit/payment_cubit.dart';

class PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final PaymentMethod method;
  final PaymentMethod selectedMethod;
  final VoidCallback onTap;
  final bool enabled;

  const PaymentMethodOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.method,
    required this.selectedMethod,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = enabled && selectedMethod == method;
    final disabledColor = ThemeColors.inkMid.withOpacity(0.5);
    final trailingLabel = enabled ? trailing : 'Coming soon';

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Container(
          margin: EdgeInsets.only(bottom: AppDimensions.md),
          padding: EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isSelected ? ThemeColors.blue : AppColors.line,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? ThemeColors.blue : disabledColor,
                size: 24.sp,
              ),
              SizedBox(width: AppDimensions.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium,
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),

              if (trailingLabel != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: 0.6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    trailingLabel,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: ThemeColors.accentInk,
                    ),
                  ),
                ),

              SizedBox(width: AppDimensions.sm),

              Radio<PaymentMethod>(
                value: method,
                groupValue: selectedMethod,
                onChanged: enabled ? (_) => onTap() : null,
                activeColor: ThemeColors.blue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}