import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../constants/app_sizes.dart';
import '../router/app_routes.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';

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
    this.onBack,
    this.actionIconSize,
    this.actionIconGap,
  });

  final String title;
  final bool centerTitle;

  final IconData? actionIcon1;
  final VoidCallback? onAction1;
  final bool showBackButton;

  final IconData? actionIcon2;
  final VoidCallback? onAction2;

  final VoidCallback? onBack;

  /// Overrides the default action-icon size (defaults to 18.sp).
  final double? actionIconSize;

  /// Overrides the default horizontal padding around each action icon —
  /// the gap between two icons is roughly double this value (defaults to 2.w).
  final double? actionIconGap;

  @override
  Size get preferredSize => Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: showBackButton,

      leading: showBackButton
          ? _AppBarIcon(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: onBack ?? () => _handleBack(context),
      )
          : null,

      title: Text(
        title,
        style: AppTextStyles.headlineMedium.copyWith(
          color: colors.textPrimary,
          fontFamily: "CormorantGaramond-Light"

        ),
      ),

      actions: [
        if (actionIcon1 != null)
          _AppBarIcon(
            icon: actionIcon1!,
            onTap: onAction1,
            size: actionIconSize,
            hPad: actionIconGap,
          ),
        if (actionIcon2 != null)
          _AppBarIcon(
            icon: actionIcon2!,
            onTap: onAction2,
            size: actionIconSize,
            hPad: actionIconGap,
          ),
        SizedBox(width: 2.w),
      ],
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }
}


class _AppBarIcon extends StatelessWidget {
  const _AppBarIcon({
    required this.icon,
    required this.onTap,
    this.size,
    this.hPad,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double? size;
  final double? hPad;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconSize = size ?? 22.sp;
    final pad = hPad ?? 2.w;

    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: colors.textPrimary),
      iconSize: iconSize,
      splashRadius: iconSize + 4,
      padding: EdgeInsets.symmetric(horizontal: pad),
      constraints: const BoxConstraints(),
    );
  }
}
