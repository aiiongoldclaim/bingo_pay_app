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

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 6.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: 18.sp, color: _textColor),
          SizedBox(width: 2.w),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: _textColor,
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
              gradient: ThemeColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
              backgroundColor: ThemeColors.white,
              foregroundColor: ThemeColors.blue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
              side: const BorderSide(color: ThemeColors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
