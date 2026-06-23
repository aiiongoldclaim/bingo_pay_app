import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/app_sizes.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_colors.dart';
import 'custom_container.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.actionIcon1,
    this.onAction1,
    this.actionIcon2,
    this.onAction2,
    this.showBackButton = true,
  });

  final String title;
  final bool centerTitle;

  final IconData? actionIcon1;
  final VoidCallback? onAction1;
  final bool showBackButton;

  final IconData? actionIcon2;
  final VoidCallback? onAction2;

  @override
  Size get preferredSize => Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,

      leading: showBackButton
          ? Padding(
              padding: EdgeInsets.only(left: 3.w),
              child: AppBarSearchAction(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            )
          : null,

      title: Text(title, style: AppTextStyles.headlineMedium),

      actions: [
        if (actionIcon1 != null)
          AppBarSearchAction(
            icon: actionIcon1!,
            onTap: onAction1,
            padding: EdgeInsets.only(right: 2.w),
          ),

        if (actionIcon2 != null)
          AppBarSearchAction(
            icon: actionIcon2!,
            onTap: onAction2,
            padding: EdgeInsets.only(right: 2.w),
          ),

        SizedBox(width: 2.w),
      ],
    );
  }
}
