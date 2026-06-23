import 'package:bingo_pay/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_colors.dart';
import '../theme/theme_colors.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String hintText;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onTap;

  final bool readOnly;
  final bool enabled;
  final bool autofocus;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final Color? backgroundColor;
  final Color? borderColor;

  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 6.5.h,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: 12.sp,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: TextStyle(
            fontSize: 17.sp,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),

          prefixIcon:
              prefixIcon ??
              Icon(Icons.search_rounded, size: 20.sp, color: AppColors.blue),

          suffixIcon: suffixIcon,

          filled: true,

          fillColor: backgroundColor ?? Colors.white,

          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.5.h,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSizes.radiusMd,
            ),
            borderSide: BorderSide(color: borderColor ?? AppColors.divider),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSizes.radiusMd,
            ),
            borderSide: const BorderSide(color: ThemeColors.inkMid, width: 0.5),
          ),

          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSizes.radiusMd,
            ),
            borderSide: BorderSide(color: AppColors.divider.withOpacity(.5)),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSizes.radiusMd,
            ),
            borderSide: BorderSide(color: borderColor ?? AppColors.divider),
          ),
        ),
      ),
    );
  }
}
