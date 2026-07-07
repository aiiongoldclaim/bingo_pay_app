import 'package:bingo_pay/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/theme_colors.dart';

enum AppButtonVariant { primary, secondary, outlined }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? prefixIcon;
  final Color? textColor;
  final Color? iconColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.prefixIcon,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
          width: double.infinity,
          height: 6.h,
          child: Container(
            decoration: BoxDecoration(
              gradient:  ThemeColors.primaryGradient,
              color:  ThemeColors.line ,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
        child: const Center(child: CircularProgressIndicator(
          color: Colors.white,
        )),
      )
          )
      );
    }

    final isDisabled = onPressed == null;
    final effectiveTextColor = isDisabled
        ? ThemeColors.inkDim
        : (textColor ?? _textColor);
    final effectiveIconColor = isDisabled
        ? ThemeColors.inkDim
        : (iconColor ?? _textColor);

    Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: 18.sp, color: effectiveIconColor),
          SizedBox(width: 2.w),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: effectiveTextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    switch (variant) {
      case AppButtonVariant.primary:
        return SizedBox(
          width: double.infinity,
          height: 6.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDisabled ? null : ThemeColors.primaryGradient,
              color: isDisabled ? ThemeColors.line : null,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: child,
            ),
          ),
        );

      case AppButtonVariant.secondary:
        return SizedBox(
          width: double.infinity,
          height: 6.h,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: isDisabled
                  ? ThemeColors.line
                  : ThemeColors.white,
              foregroundColor: ThemeColors.inkDim,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: child,
          ),
        );

      case AppButtonVariant.outlined:
        return SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: isDisabled ? ThemeColors.line : null,
              side: BorderSide(
                color: isDisabled ? ThemeColors.line : ThemeColors.inkDim,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: child,
          ),
        );
    }
  }

  Color get _textColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.white;

      case AppButtonVariant.secondary:
      case AppButtonVariant.outlined:
        return ThemeColors.red;
    }
  }
}
