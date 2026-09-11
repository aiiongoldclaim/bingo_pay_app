import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'profile_menu_list.dart';
import 'profile_metrics.dart';

/// "Account & Support" group — secondary menu items plus a Logout row.
/// Reuses [ProfileMenuList] instead of a bespoke tile/container implementation.
class ProfileSecondaryGroup extends StatelessWidget {
  const ProfileSecondaryGroup({
    super.key,
    required this.metrics,
    required this.isLoggingOut,
  });

  final ProfileMetrics metrics;
  final bool isLoggingOut;

  static const _logoutItem = ProfileMenuItem(
    title: 'Logout',
    subtitle: 'Sign out from your profile',
    iconAsset: 'logout',
    route: '',
  );

  Future<void> _confirmLogout(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Logout?',
      message: 'Are you sure you want to logOut from your profile',
      confirmLabel: 'Logout',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.logout_rounded,
      confirmColor: context.c.error,
    );

    if (!confirmed) return;

    authBloc.add(const LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return ProfileMenuList(
      items: const [...ProfileMenuItem.secondaryItems, _logoutItem],
      onTap: (item) {
        if (item == _logoutItem) {
          if (!isLoggingOut) _confirmLogout(context);
          return;
        }
        if (item.route.isNotEmpty) context.push(item.route);
      },
    );
  }
}

class ProfileLogoutOverlay extends StatelessWidget {
  const ProfileLogoutOverlay({super.key, required this.metrics});

  final ProfileMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Positioned.fill(
      child: Container(
        color: colors.textPrimary.withValues(alpha: 0.45),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: m.walletHPad * 1.8,
              vertical: m.gapLg,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(m.menuRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: colors.brand),
                SizedBox(height: m.gapMd),
                Text(
                  'Logging out...',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: m.menuTitleSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
