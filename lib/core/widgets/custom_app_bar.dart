import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/app_sizes.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.centerTitle = false,
    this.actionIcon1,
    this.onAction1,
    this.actionIcon2,
    this.onAction2,
  });

  final String title;
  final Widget? leading;
  final bool centerTitle;

  final IconData? actionIcon1;
  final VoidCallback? onAction1;

  final IconData? actionIcon2;
  final VoidCallback? onAction2;

  @override
  Size get preferredSize => Size.fromHeight(AppSizes.appBarHeight);

  Widget _buildActionButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: ThemeColors.line),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: AppSizes.iconMd, color: ThemeColors.ink),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,

      leading: leading == null
          ? null
          : Container(
              margin: EdgeInsets.only(left: 3.w),
              decoration: BoxDecoration(
                color: ThemeColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: ThemeColors.line),
              ),
              child: leading,
            ),

      title: Text(title, style: AppTextStyles.headlineMedium),

      actions: [
        if (actionIcon1 != null) _buildActionButton(actionIcon1!, onAction1),

        if (actionIcon2 != null) _buildActionButton(actionIcon2!, onAction2),

        SizedBox(width: 2.w),
      ],
    );
  }
}
