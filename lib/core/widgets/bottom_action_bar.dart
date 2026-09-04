import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_theme_colors.dart';
import 'app_button.dart';

class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({
    super.key,
    this.price,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.secondaryTextColor,
    this.secondaryIconColor,
    this.secondaryIcon,
    this.secondaryVariant = AppButtonVariant.outlined,
    this.secondaryLoading = false,
    this.primaryLoading = false,
    this.buttonHeight,
    this.buttonFontSize,
  });

  final String? price;

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final bool primaryLoading;

  /// Null ho to sirf primary button dikhega (full width)
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final IconData? secondaryIcon;
  final AppButtonVariant secondaryVariant;
  final Color? secondaryTextColor;
  final Color? secondaryIconColor;
  final bool secondaryLoading;

  /// Screen ke Metrics se pass kar sakti ho
  final double? buttonHeight;
  final double? buttonFontSize;

  bool get _hasPrice => price != null && price != 'N/A';
  bool get _hasSecondary => secondaryLabel != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: colors.isDark
            ? null
            : [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_hasPrice) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: colors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    price!,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 4.w),
            ],

            /// Secondary — Add to Cart / Go to Cart
            if (_hasSecondary) ...[
              Expanded(
                child: AppButton(
                  label: secondaryLabel!,
                  prefixIcon: secondaryIcon,
                  variant: secondaryVariant,
                  textColor: secondaryTextColor,
                  iconColor: secondaryIconColor,
                  isLoading: secondaryLoading,
                  height: buttonHeight,
                  fontSize: buttonFontSize,
                  onPressed: onSecondaryPressed,
                ),
              ),
              SizedBox(width: 3.w),
            ],

            /// Primary — Buy Now / Checkout
            Expanded(
              child: AppButton(
                label: primaryLabel,
                variant: AppButtonVariant.primary,
                isLoading: primaryLoading,
                height: buttonHeight,
                fontSize: buttonFontSize,
                onPressed: onPrimaryPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}