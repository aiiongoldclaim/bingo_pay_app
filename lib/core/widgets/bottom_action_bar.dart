import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/currency_constants.dart';
import '../theme/theme_colors.dart';
import 'app_button.dart';

class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({
    super.key,
    this.price,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.onSecondaryPressed,
    this.secondaryTextColor,
    this.secondaryIconColor,
    this.secondaryIcon,
    this.secondaryVariant = AppButtonVariant.outlined,
  });

  final String? price;

  final String primaryLabel;
  final VoidCallback onPrimaryPressed;

  final String secondaryLabel;
  final VoidCallback onSecondaryPressed;
  final IconData? secondaryIcon;
  final AppButtonVariant secondaryVariant;
  final Color? secondaryTextColor;
  final Color? secondaryIconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        boxShadow: [
          BoxShadow(
            color: ThemeColors.ink.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            /// Price (optional)
            if (price != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: ThemeColors.inkDim,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Text(
                    '${CurrencyConstants.dollar}${price!}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.ink,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 4.w),
            ],

            /// Secondary Button
            Expanded(
              child: AppButton(
                label: secondaryLabel,
                prefixIcon: secondaryIcon,
                variant: secondaryVariant,
                textColor: secondaryTextColor,
                iconColor: secondaryIconColor,
                onPressed: onSecondaryPressed,
              ),
            ),

            SizedBox(width: 3.w),

            /// Primary Button
            Expanded(
              child: AppButton(
                label: primaryLabel,
                variant: AppButtonVariant.primary,
                onPressed: onPrimaryPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
