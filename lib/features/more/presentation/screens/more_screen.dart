import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/security/email_qr_codec.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(title: const Text('Profile')),
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
                    const SizedBox(height: AppDimensions.sm),
                    ElevatedButton(onPressed: _retry, child: const Text('Retry')),
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
    final email = vendor.email ??
        (authState is AuthAuthenticated ? authState.user.email : null);
    final hasContactInfo =
        vendor.email != null || vendor.phone != null || vendor.supportEmail != null || vendor.supportPhone != null;
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.md),
      children: [
        _ProfileHeaderCard(vendor: vendor, kycStatus: bingold.kycStatus),
        const SizedBox(height: AppDimensions.md),
        _SectionCard(
          title: 'Wallet QR Code',
          subtitle: 'Scan to receive payments, or copy the address',
          titleIcon: Icons.qr_code_2,
          titleIconColor: AppColors.primary,
          highlight: true,
          children: [
            _WalletAddressCarousel(
              walletAddresses: bingold.walletAddresses,
              email: email,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        _SectionCard(
          title: 'Shop',
          titleIcon: Icons.storefront_outlined,
          titleIconColor: AppColors.info,
          children: [
            _IconInfoRow(
              icon: Icons.storefront_outlined,
              iconColor: AppColors.info,
              iconBackground: AppColors.infoTint,
              label: 'Shop name',
              value: vendor.shopName,
            ),
            if (vendor.businessName != null)
              _IconInfoRow(
                icon: Icons.business_outlined,
                iconColor: AppColors.accentPurple,
                iconBackground: AppColors.accentPurpleTint,
                label: 'Business name',
                value: vendor.businessName!,
              ),
            if (vendor.merchantCode != null)
              _IconInfoRow(
                icon: Icons.confirmation_number_outlined,
                iconColor: const Color(0xFFB36B00),
                iconBackground: AppColors.warningTint,
                label: 'Merchant code',
                value: vendor.merchantCode!,
              ),
          ],
        ),
        if (hasContactInfo) ...[
          const SizedBox(height: AppDimensions.md),
          _SectionCard(
            title: 'Contact',
            titleIcon: Icons.headset_mic_outlined,
            titleIconColor: AppColors.success,
            children: [
              if (vendor.email != null)
                _IconInfoRow(
                  icon: Icons.email_outlined,
                  iconColor: AppColors.info,
                  iconBackground: AppColors.infoTint,
                  label: 'Email',
                  value: vendor.email!,
                ),
              if (vendor.phone != null)
                _IconInfoRow(
                  icon: Icons.phone_outlined,
                  iconColor: AppColors.success,
                  iconBackground: AppColors.successTint,
                  label: 'Phone',
                  value: vendor.phone!,
                ),
              if (vendor.supportEmail != null)
                _IconInfoRow(
                  icon: Icons.support_agent_outlined,
                  iconColor: AppColors.accentPurple,
                  iconBackground: AppColors.accentPurpleTint,
                  label: 'Support email',
                  value: vendor.supportEmail!,
                ),
              if (vendor.supportPhone != null)
                _IconInfoRow(
                  icon: Icons.headset_mic_outlined,
                  iconColor: const Color(0xFFB36B00),
                  iconBackground: AppColors.warningTint,
                  label: 'Support phone',
                  value: vendor.supportPhone!,
                ),
            ],
          ),
        ],
        const SizedBox(height: AppDimensions.md),
        _SectionCard(
          title: 'Balances',
          titleIcon: Icons.account_balance_outlined,
          titleIconColor: const Color(0xFFB36B00),
          children: [_BalancesRow(balances: bingold.balances)],
        ),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final VendorInfoModel vendor;
  final String kycStatus;

  const _ProfileHeaderCard({required this.vendor, required this.kycStatus});

  @override
  Widget build(BuildContext context) {
    final initial = vendor.shopName.isNotEmpty ? vendor.shopName[0].toUpperCase() : '?';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.shopName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (vendor.businessName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    vendor.businessName!,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                  ),
                ],
                const SizedBox(height: AppDimensions.sm),
                Wrap(
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
  if (s.contains('active') || s.contains('approved') || s.contains('verified')) {
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
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 12, color: meta.color),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: meta.color),
          ),
        ],
      ),
    );
  }
}

class _IconInfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;

  const _IconInfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalancesRow extends StatelessWidget {
  final List<BalanceModel> balances;

  const _BalancesRow({required this.balances});

  static const _accentColors = [
    AppColors.info,
    AppColors.accentPurple,
    AppColors.success,
    Color(0xFFB36B00),
  ];

  String _formatBalance(double value) {
    return value.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...balances]..sort((a, b) => a.fullName.compareTo(b.fullName));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(sorted.length, (index) {
          final balance = sorted[index];
          final accent = _accentColors[index % _accentColors.length];
          return Padding(
            padding: EdgeInsets.only(right: index == sorted.length - 1 ? 0 : AppDimensions.sm),
            child: Container(
              width: 140,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent.withValues(alpha: 0.12), accent.withValues(alpha: 0.03)],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border(left: BorderSide(color: accent, width: 4)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                      child: Image.network(
                        balance.iconUrl,
                        width: 28,
                        height: 28,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.toll_outlined, color: accent, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    balance.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatBalance(balance.totalBalance / 100000000),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? titleIcon;
  final Color? titleIconColor;
  final bool highlight;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.subtitle,
    this.titleIcon,
    this.titleIconColor,
    this.highlight = false,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final accent = titleIconColor ?? AppColors.primary;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: highlight ? 0.1 : 0.05),
            blurRadius: highlight ? 20 : 12,
            offset: Offset(0, highlight ? 8 : 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highlight) Container(height: 4, color: accent),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (titleIcon != null) ...[
                      Icon(titleIcon, size: highlight ? 20 : 18, color: accent),
                      const SizedBox(width: AppDimensions.xs),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: highlight ? 17 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: AppDimensions.sm),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletAddressCarousel extends StatefulWidget {
  final Map<String, String> walletAddresses;
  final String? email;

  const _WalletAddressCarousel({required this.walletAddresses, this.email});

  @override
  State<_WalletAddressCarousel> createState() => _WalletAddressCarouselState();
}

class _WalletAddressCarouselState extends State<_WalletAddressCarousel> {
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
    final hasEmail = widget.email != null;
    final totalCount = entries.length + (hasEmail ? 1 : 0);
    return Column(
      children: [
        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalCount,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              if (hasEmail && index == 0) {
                return _EmailQrPage(email: widget.email!);
              }
              final entry = entries[hasEmail ? index - 1 : index];
              return _WalletAddressPage(
                currency: entry.key.toUpperCase(),
                address: entry.value,
                truncatedAddress: _truncate(entry.value),
                onCopy: () => _copyAddress(entry.value),
              );
            },
          ),
        ),
        if (totalCount > 1) ...[
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: index == _currentPage ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                  color: index == _currentPage
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmailQrPage extends StatelessWidget {
  final String email;

  const _EmailQrPage({required this.email});

  @override
  Widget build(BuildContext context) {
    final payload = EmailQrCodec.encrypt(email);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
            ),
            child: const Text(
              'MY QR',
              style: TextStyle(
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: QrImageView(data: payload, size: 240),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            email,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletAddressPage extends StatelessWidget {
  final String currency;
  final String address;
  final String truncatedAddress;
  final VoidCallback onCopy;

  const _WalletAddressPage({
    required this.currency,
    required this.address,
    required this.truncatedAddress,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
            ),
            child: Text(
              currency,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: QrImageView(data: address, size: 240),
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            padding: const EdgeInsets.only(left: AppDimensions.md, right: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F4),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  truncatedAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                IconButton(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy, size: AppDimensions.iconSm),
                  color: AppColors.primary,
                  tooltip: 'Copy address',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
