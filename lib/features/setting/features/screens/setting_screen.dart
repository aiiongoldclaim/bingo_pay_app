import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/settings_metrics.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = true;
  bool _orderAlerts = true;
  bool _biometric = false;

  Future<void> _confirmLogout() async {
    final authBloc = context.read<AuthBloc>();

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Logout?',
      message: 'Are you sure you want to logOut from your account',
      confirmLabel: 'Logout',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );

    if (!confirmed) return;
    authBloc.add(const LogoutRequested());
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete account?',
      message:
      'This will permanently remove your account and all its data. This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.delete_forever_outlined,
    );

    if (!confirmed || !mounted) return;
    AppSnackbar.showError(context, 'Account deletion is not available yet');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Builder(
          builder: (context) {
            final m = SettingsMetrics.of(context);

            return Column(
              children: [
                SettingsTopBar(
                  metrics: m,
                  title: 'Settings',
                  subtitle: 'Manage your preferences',
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.account),
                ),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: m.gapMd,
                          bottom: m.gapLg * 2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Account ───────────────────────────────
                            SettingsSectionHeading(
                              metrics: m,
                              label: 'Account',
                            ),
                            SizedBox(height: m.sectionGap),
                            SettingsCard(
                              metrics: m,
                              children: [
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.person_outline_rounded,
                                  title: 'Edit Profile',
                                  subtitle: 'Update your personal details',
                                  onTap: () =>
                                      context.push(AppRoutes.editProfile),
                                ),
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.location_on_outlined,
                                  title: 'Saved Addresses',
                                  subtitle: 'Manage delivery addresses',
                                  onTap: () =>
                                      context.push(AppRoutes.buyerAddresses),
                                ),
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.account_balance_wallet_outlined,
                                  title: 'Bingold Wallet',
                                  subtitle: 'Balance and transactions',
                                  onTap: () => context.push(AppRoutes.wallet),
                                ),
                              ],
                            ),

                            SizedBox(height: m.gapLg),

                            // ── Notifications ─────────────────────────
                            SettingsSectionHeading(
                              metrics: m,
                              label: 'Notifications',
                            ),
                            SizedBox(height: m.sectionGap),
                            SettingsCard(
                              metrics: m,
                              children: [
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.notifications_outlined,
                                  title: 'Push Notifications',
                                  subtitle: 'Offers, updates and more',
                                  switchValue: _pushNotifications,
                                  onSwitchChanged: (v) =>
                                      setState(() => _pushNotifications = v),
                                ),
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.local_shipping_outlined,
                                  title: 'Order Alerts',
                                  subtitle: 'Shipping and delivery updates',
                                  switchValue: _orderAlerts,
                                  onSwitchChanged: (v) =>
                                      setState(() => _orderAlerts = v),
                                ),
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.mail_outline_rounded,
                                  title: 'Email Updates',
                                  subtitle: 'Newsletters and promotions',
                                  switchValue: _emailUpdates,
                                  onSwitchChanged: (v) =>
                                      setState(() => _emailUpdates = v),
                                ),
                              ],
                            ),

                            SizedBox(height: m.gapLg),

                            // ── Security ──────────────────────────────
                            SettingsSectionHeading(
                              metrics: m,
                              label: 'Security',
                            ),
                            SizedBox(height: m.sectionGap),
                            SettingsCard(
                              metrics: m,
                              children: [
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.fingerprint_rounded,
                                  title: 'Biometric Login',
                                  subtitle: 'Unlock with fingerprint or face',
                                  switchValue: _biometric,
                                  onSwitchChanged: (v) =>
                                      setState(() => _biometric = v),
                                ),
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.lock_outline_rounded,
                                  title: 'Change Password',
                                  subtitle: 'Update your login password',
                                  onTap: () =>
                                      context.push(AppRoutes.forgotPassword),
                                ),
                              ],
                            ),

                            SizedBox(height: m.gapLg),

                            // ── Support & About ───────────────────────
                            SettingsSectionHeading(
                              metrics: m,
                              label: 'Support & About',
                            ),
                            SizedBox(height: m.sectionGap),
                            SettingsCard(
                              metrics: m,
                              children: [
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.headset_mic_outlined,
                                  title: 'Help & Support',
                                  subtitle: 'FAQs and contact us',
                                  onTap: () => context.push(AppRoutes.help),
                                ),
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.privacy_tip_outlined,
                                  title: 'Privacy Policy',
                                  onTap: () {},
                                ),
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.description_outlined,
                                  title: 'Terms of Service',
                                  onTap: () {},
                                ),
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.info_outline_rounded,
                                  title: 'App Version',
                                  trailingValue: '1.0.0',
                                  onTap: () {},
                                ),
                              ],
                            ),

                            SizedBox(height: m.gapLg),

                            // ── Danger zone ───────────────────────────
                            SettingsCard(
                              metrics: m,
                              children: [
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.logout_rounded,
                                  title: 'Logout',
                                  subtitle: 'Sign out from your account',
                                  onTap: _confirmLogout,
                                ),
                                SettingsTile(
                                  metrics: m,
                                  icon: Icons.delete_outline_rounded,
                                  title: 'Delete Account',
                                  subtitle: 'Permanently remove your data',
                                  isDestructive: true,
                                  onTap: _confirmDeleteAccount,
                                ),
                              ],
                            ),

                            SizedBox(height: m.gapLg),

                            Center(
                              child: Text(
                                'TheVaults · v1.0.0',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: colors.textMuted,
                                  fontFamily: 'Inter',
                                  fontSize: m.tileSubSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}