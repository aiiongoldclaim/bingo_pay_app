import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/app_sizes.dart';
import '../theme/theme_colors.dart';

class AppBarSearchAction extends StatelessWidget {
  const AppBarSearchAction({
    super.key,
    required this.icon,
    this.onTap,
    this.padding,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(right: 4.w),
      child: Container(
        width: 11.w,
        height: 11.w,
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: ThemeColors.line),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          icon: Icon(icon, color: ThemeColors.black, size: AppSizes.iconMd),
        ),
      ),
    );
  }
}
