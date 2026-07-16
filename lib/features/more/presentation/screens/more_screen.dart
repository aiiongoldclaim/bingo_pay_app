import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/email_qr_sheet.dart';
import '../../../../core/widgets/glass/glass_border.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/models/vendor_profile_model.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late Future<VendorProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = getIt<ProfileRemoteDataSource>().getProfile();
  }

  void _retry() {
    setState(() {
      _profileFuture = getIt<ProfileRemoteDataSource>().getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: FutureBuilder<VendorProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load profile.'),
                    const SizedBox(height: AppDimensions.md),
                    AppButton(label: 'Retry', onPressed: _retry),
                  ],
                ),
              ),
            );
          }
          return _ProfileBody(profile: snapshot.data!);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final VendorProfileModel profile;

  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    final vendor = profile.vendor;
    final bingold = profile.bingold;
    final authState = context.read<AuthBloc>().state;
    final email =
        vendor.email ??
        (authState is AuthAuthenticated ? authState.user.email : null);

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _HeroHeader(
          vendor: vendor,
          kycStatus: bingold.kycStatus,
          email: email,
          walletAddresses: bingold.walletAddresses,
        ),
        const SizedBox(height: AppDimensions.lg),
        if (bingold.balances.isNotEmpty) ...[
          _BalancesSection(balances: bingold.balances),
          const SizedBox(height: AppDimensions.lg),
        ],
        _InfoGroup(
          title: 'Shop details',
          rows: [
            _InfoRowData(
              icon: Icons.storefront_outlined,
              label: 'Shop name',
              value: vendor.shopName,
            ),
            if (vendor.businessName != null)
              _InfoRowData(
                icon: Icons.business_outlined,
                label: 'Business name',
                value: vendor.businessName!,
              ),
            if (vendor.merchantCode != null)
              _InfoRowData(
                icon: Icons.confirmation_number_outlined,
                label: 'Merchant code',
                value: vendor.merchantCode!,
                copyable: true,
              ),
          ],
        ),
        if (vendor.email != null ||
            vendor.phone != null ||
            vendor.supportEmail != null ||
            vendor.supportPhone != null) ...[
          const SizedBox(height: AppDimensions.lg),
          _InfoGroup(
            title: 'Contact',
            rows: [
              if (vendor.email != null)
                _InfoRowData(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: vendor.email!,
                  copyable: true,
                ),
              if (vendor.phone != null)
                _InfoRowData(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: vendor.phone!,
                ),
              if (vendor.supportEmail != null)
                _InfoRowData(
                  icon: Icons.support_agent_outlined,
                  label: 'Support email',
                  value: vendor.supportEmail!,
                  copyable: true,
                ),
              if (vendor.supportPhone != null)
                _InfoRowData(
                  icon: Icons.headset_mic_outlined,
                  label: 'Support phone',
                  value: vendor.supportPhone!,
                ),
            ],
          ),
        ],
        const SizedBox(height: AppDimensions.xl),
        const _LogoutSection(),
        const SizedBox(height: AppDimensions.xl),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final VendorInfoModel vendor;
  final String kycStatus;
  final String? email;
  final Map<String, String> walletAddresses;

  const _HeroHeader({
    required this.vendor,
    required this.kycStatus,
    required this.email,
    required this.walletAddresses,
  });

  static const double _actionsOverlap = 44;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final initial = vendor.shopName.isNotEmpty
        ? vendor.shopName[0].toUpperCase()
        : '?';
    final hasSupport =
        vendor.supportEmail != null || vendor.supportPhone != null;

    final actions = <_QuickAction>[
      if (email != null)
        _QuickAction(
          icon: Icons.qr_code_2,
          label: 'My QR',
          onTap: () => showEmailQrSheet(context, email: email!),
        ),
      if (walletAddresses.isNotEmpty)
        _QuickAction(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Wallet QRs',
          onTap: () => _showWalletQrSheet(context, walletAddresses),
        ),
      if (hasSupport)
        _QuickAction(
          icon: Icons.support_agent_outlined,
          label: 'Support',
          onTap: () => _showSupportSheet(
            context,
            supportEmail: vendor.supportEmail,
            supportPhone: vendor.supportPhone,
          ),
        ),
    ];

    return Padding(
      // Reserve space for the quick-actions card hanging below the hero.
      padding: EdgeInsets.only(bottom: actions.isEmpty ? 0 : _actionsOverlap),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              AppDimensions.lg,
              topInset + AppDimensions.lg,
              AppDimensions.lg,
              actions.isEmpty
                  ? AppDimensions.lg
                  : _actionsOverlap + AppDimensions.lg,
            ),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, Color(0xFF4F68B8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  vendor.shopName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                if (vendor.businessName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    vendor.businessName!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.sm),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppDimensions.xs,
                  runSpacing: AppDimensions.xs,
                  children: [
                    _StatusBadge(label: vendor.status),
                    _StatusBadge(label: 'KYC: $kycStatus'),
                  ],
                ),
              ],
            ),
          ),
          if (actions.isNotEmpty)
            Positioned(
              left: AppDimensions.md,
              right: AppDimensions.md,
              bottom: -_actionsOverlap,
              child: _QuickActionsCard(actions: actions),
            ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _QuickActionsCard extends StatelessWidget {
  final List<_QuickAction> actions;

  const _QuickActionsCard({required this.actions});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: AppDimensions.radiusXl,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
      child: Row(
        children: [
          for (final action in actions)
            Expanded(
              child: InkWell(
                onTap: action.onTap,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action.icon,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      action.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusMeta {
  final Color color;
  final IconData icon;

  const _StatusMeta(this.color, this.icon);
}

_StatusMeta _statusMeta(String status) {
  final s = status.toLowerCase();
  if (s.contains('reject') || s.contains('suspend') || s.contains('block')) {
    return const _StatusMeta(AppColors.error, Icons.cancel_outlined);
  }
  if (s.contains('pending') || s.contains('review')) {
    return const _StatusMeta(Color(0xFFB36B00), Icons.schedule_outlined);
  }
  if (s.contains('active') ||
      s.contains('approved') ||
      s.contains('verified')) {
    return const _StatusMeta(AppColors.success, Icons.check_circle_outline);
  }
  return const _StatusMeta(AppColors.info, Icons.info_outline);
}

class _StatusBadge extends StatelessWidget {
  final String label;

  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(label);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        border: Border.all(color: meta.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 12, color: meta.color),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: meta.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.md + AppDimensions.xs,
        right: AppDimensions.md,
        bottom: AppDimensions.sm,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

class _BalancesSection extends StatelessWidget {
  final List<BalanceModel> balances;

  const _BalancesSection({required this.balances});

  String _formatBalance(double value) {
    return value
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...balances]
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'BALANCES'),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            itemCount: sorted.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppDimensions.sm),
            itemBuilder: (context, index) {
              final balance = sorted[index];
              return GlassCard(
                radius: AppDimensions.radiusXl,
                padding: const EdgeInsets.all(AppDimensions.md),
                child: SizedBox(
                  width: 118,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusCircular,
                          ),
                          child: Image.network(
                            balance.iconUrl,
                            width: 22,
                            height: 22,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.toll_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.xs),
                        Expanded(
                          child: Text(
                            balance.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _formatBalance(balance.totalBalance / 100000000),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  const _InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
  });
}

class _InfoGroup extends StatelessWidget {
  final String title;
  final List<_InfoRowData> rows;

  const _InfoGroup({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title.toUpperCase()),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.glass.fill,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: GlassBorder(context.glass),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: AppDimensions.md + 20 + AppDimensions.sm,
                    color: context.glass.border,
                  ),
                _InfoRow(data: rows[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final _InfoRowData data;

  const _InfoRow({required this.data});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: data.value));
    if (context.mounted) {
      AppSnackbar.showSuccess(context, '${data.label} copied to clipboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.copyable ? () => _copy(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(data.icon, size: 20, color: context.colors.textSecondary),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    data.value,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (data.copyable)
              Icon(
                Icons.copy,
                size: AppDimensions.iconSm,
                color: context.colors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

class _LogoutSection extends StatelessWidget {
  const _LogoutSection();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
        ),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Log out',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

Future<void> _showWalletQrSheet(
  BuildContext context,
  Map<String, String> walletAddresses,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusXl),
      ),
    ),
    builder: (context) => _WalletQrSheet(walletAddresses: walletAddresses),
  );
}

class _WalletQrSheet extends StatefulWidget {
  final Map<String, String> walletAddresses;

  const _WalletQrSheet({required this.walletAddresses});

  @override
  State<_WalletQrSheet> createState() => _WalletQrSheetState();
}

class _WalletQrSheetState extends State<_WalletQrSheet> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _copyAddress(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (mounted) {
      AppSnackbar.showSuccess(context, 'Address copied to clipboard');
    }
  }

  String _truncate(String address) {
    if (address.length <= 14) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.walletAddresses.entries.toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Wallet addresses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Scan to receive payments, or copy the address',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            SizedBox(
              height: 330,
              child: PageView.builder(
                controller: _pageController,
                itemCount: entries.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusCircular,
                          ),
                        ),
                        child: Text(
                          entry.key.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.sm),
                        decoration: BoxDecoration(
                          // QR codes need a light background to stay scannable
                          // in dark mode.
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: QrImageView(data: entry.value, size: 200),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Container(
                        padding: const EdgeInsets.only(
                          left: AppDimensions.md,
                          right: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.inputFill,
                          border: Border.all(color: context.colors.border),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusCircular,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _truncate(entry.value),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                            ),
                            IconButton(
                              onPressed: () => _copyAddress(entry.value),
                              icon: const Icon(
                                Icons.copy,
                                size: AppDimensions.iconSm,
                              ),
                              color: AppColors.primary,
                              tooltip: 'Copy address',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (entries.length > 1) ...[
              const SizedBox(height: AppDimensions.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  entries.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: index == _currentPage ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCircular,
                      ),
                      color: index == _currentPage
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _showSupportSheet(
  BuildContext context, {
  String? supportEmail,
  String? supportPhone,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusXl),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Support',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            if (supportEmail != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.support_agent_outlined),
                title: const Text('Support email'),
                subtitle: Text(supportEmail),
                trailing: const Icon(Icons.copy, size: AppDimensions.iconSm),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: supportEmail));
                  if (sheetContext.mounted) {
                    AppSnackbar.showSuccess(
                      sheetContext,
                      'Support email copied to clipboard',
                    );
                  }
                },
              ),
            if (supportPhone != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.headset_mic_outlined),
                title: const Text('Support phone'),
                subtitle: Text(supportPhone),
                trailing: const Icon(Icons.copy, size: AppDimensions.iconSm),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: supportPhone));
                  if (sheetContext.mounted) {
                    AppSnackbar.showSuccess(
                      sheetContext,
                      'Support phone copied to clipboard',
                    );
                  }
                },
              ),
          ],
        ),
      ),
    ),
  );
}
