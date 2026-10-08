import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/public_settings_entity.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/settings_metrics.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _localNotifications = getIt<LocalNotificationService>();
  late bool _pushNotifications = _localNotifications.isEnabled;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadPublicSettings();
  }

  Future<void> _onPushNotificationsChanged(bool value) async {
    setState(() => _pushNotifications = value);
    final enabled = await _localNotifications.setEnabled(value);
    if (!mounted) return;
    setState(() => _pushNotifications = enabled);
    if (value && !enabled) {
      AppSnackbar.showError(
        context,
        'Notification permission denied. Allow it from phone settings.',
      );
    }
  }

  Future<void> _launch(Uri uri, String errorMessage) async {
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }

    if (!launched && mounted) {
      AppSnackbar.showError(context, errorMessage);
    }
  }

  void _openMap(CompanyInfoEntity company) {
    final query = company.latitude != null && company.longitude != null
        ? '${company.latitude},${company.longitude}'
        : company.fullAddress;
    _launch(
      Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query}),
      'Could not open maps.',
    );
  }

  Widget _buildContactCard(SettingsMetrics m, SettingsState state) {
    if (state is SettingsError) {
      return SettingsCard(
        metrics: m,
        children: [
          SettingsTile(
            metrics: m,
            icon: Icons.refresh_rounded,
            title: 'Could not load contact details',
            subtitle: 'Tap to retry',
            onTap: () => context
                .read<SettingsCubit>()
                .loadPublicSettings(force: true),
          ),
        ],
      );
    }

    if (state is! SettingsLoaded) {
      return SettingsCard(
        metrics: m,
        children: [
          Padding(
            padding: EdgeInsets.all(m.gapLg),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ],
      );
    }

    final company = state.settings.company;

    return SettingsCard(
      metrics: m,
      children: [
        if (company.email.isNotEmpty)
          SettingsTile(
            metrics: m,
            icon: Icons.mail_outline_rounded,
            title: 'Email Us',
            subtitle: company.email,
            onTap: () => _launch(
              Uri(scheme: 'mailto', path: company.email),
              'Could not open email app.',
            ),
          ),
        if (company.phone.isNotEmpty)
          SettingsTile(
            metrics: m,
            icon: Icons.call_outlined,
            title: 'Call Us',
            subtitle: company.phone,
            onTap: () => _launch(
              Uri(scheme: 'tel', path: company.phone.replaceAll(' ', '')),
              'Could not open dialer.',
            ),
          ),
        if (company.website.isNotEmpty)
          SettingsTile(
            metrics: m,
            icon: Icons.language_rounded,
            title: 'Website',
            subtitle: company.website,
            onTap: () => _launch(
              Uri.parse(company.website),
              'Could not open the website.',
            ),
          ),
        if (company.fullAddress.isNotEmpty)
          SettingsTile(
            metrics: m,
            icon: Icons.location_city_outlined,
            title: 'Our Office',
            subtitle: company.fullAddress,
            onTap: () => _openMap(company),
          ),
      ],
    );
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
                      : context.go(AppRoutes.profile),
                ),

                Expanded(
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
                                title: 'BiGod Wallet',
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
                                onSwitchChanged: _onPushNotificationsChanged,
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
                              // SettingsTile(
                              //   metrics: m,
                              //   icon: Icons.privacy_tip_outlined,
                              //   title: 'Privacy Policy',
                              //   subtitle: 'How we handle your data',
                              //   onTap: () {},
                              // ),
                              // SettingsTile(
                              //   metrics: m,
                              //   icon: Icons.description_outlined,
                              //   title: 'Terms of Service',
                              //   subtitle: 'Rules for using the app',
                              //   onTap: () {},
                              // ),
                              SettingsTile(
                                metrics: m,
                                icon: Icons.info_outline_rounded,
                                title: 'App Version',
                                subtitle: 'Current installed version',
                                trailingValue: '1.0.0',
                                onTap: () {},
                              ),
                            ],
                          ),

                          SizedBox(height: m.gapLg),

                          // ── Contact Us ────────────────────────────
                          SettingsSectionHeading(
                            metrics: m,
                            label: 'Contact Us',
                          ),
                          SizedBox(height: m.sectionGap),
                          BlocBuilder<SettingsCubit, SettingsState>(
                            builder: (context, state) =>
                                _buildContactCard(m, state),
                          ),

                          SizedBox(height: m.gapLg),

                          // ── Danger zone ───────────────────────────
                          SettingsCard(
                            metrics: m,
                            children: [
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
                        ],
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