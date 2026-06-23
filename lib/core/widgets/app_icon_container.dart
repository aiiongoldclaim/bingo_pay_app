import 'package:bingo_pay/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/theme_colors.dart';

class AppIconContainer extends StatelessWidget {
  const AppIconContainer({
    super.key,
    this.icon,
    this.text,
    this.onTap,
    this.size,
    this.iconColor,
    this.textColor,
    this.backgroundColor,
  });

  final IconData? icon;
  final String? text;
  final VoidCallback? onTap;
  final double? size;

  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final containerSize = size ?? 12.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: backgroundColor ?? ThemeColors.white.withOpacity(.35),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: iconColor ?? ThemeColors.white, size: 22.sp)
              : Text(
                  text ?? '',
                  style: TextStyle(
                    color: textColor ?? ThemeColors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
