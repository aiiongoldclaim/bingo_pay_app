import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/svg_image.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';
import '../../domain/enities/profile_entity.dart';
import 'profile_metrics.dart';

// Who is signed in (tap to edit), and their BiGod and TVS Wallet balances.
class ProfileHeader extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback onEdit;
  final VoidCallback onWalletTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEdit,
    required this.onWalletTap,
  });

  String _formatBalance(double value) {
    String s = value.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final m = ProfileMetrics.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: m.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AvatarRow(profile: profile, metrics: m, onEdit: onEdit),
              SizedBox(height: m.gapMd),
              _WalletCard(
                formattedBalance: _formatBalance(profile.displayBigoldBalance),
                metrics: m,
                onTap: onWalletTap,
                tvs: _TvsWalletRow(profile: profile, metrics: m),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  final ProfileEntity profile;
  final ProfileMetrics metrics;
  final VoidCallback onEdit;

  const _AvatarRow({
    required this.profile,
    required this.metrics,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = metrics;
    final size = m.avatarSize * 0.8;
    final badge = m.cameraBadgeSize * 0.85;

    final initials = Text(
      profile.initials,
      style: AppTextStyles.titleLarge.copyWith(
        color: colors.brand,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: m.avatarInitialSize * 0.65,
      ),
    );
    final fallback = profile.initials.isEmpty
        ? Icon(Icons.person_rounded, size: size * 0.55, color: colors.brand)
        : initials;
    final image = profile.profileImageUrl;

    return Semantics(
      button: true,
      label: 'Edit profile',
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(m.menuRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: m.gapXs),
          child: Row(
            children: [
              SizedBox(
                width: size,
                height: size,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: colors.brandSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      child: image == null || image.isEmpty
                          ? fallback
                          : Image.network(
                              image,
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => fallback,
                            ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: badge,
                        height: badge,
                        decoration: BoxDecoration(
                          color: colors.brand,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.background,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: badge * 0.5,
                          color: colors.onBrand,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: m.avatarGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: colors.textPrimary,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: m.nameSize,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (profile.kycStatus.isVerified) ...[
                          SizedBox(width: m.gapXs),
                          Icon(
                            Icons.verified_rounded,
                            size: m.nameSize,
                            color: colors.brand,
                            semanticLabel: 'Verified',
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: m.gapXs * 0.6),
                    Text(
                      profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.emailSize * 0.9,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: m.chevronSize + 6,
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final String formattedBalance;
  final ProfileMetrics metrics;
  final VoidCallback onTap;
  final Widget tvs;

  const _WalletCard({
    required this.formattedBalance,
    required this.metrics,
    required this.onTap,
    required this.tvs,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = metrics;
    final corner = Radius.circular(m.walletRadius + 6);
    final muted = colors.onBrand.withValues(alpha: 0.75);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(corner),
          gradient: LinearGradient(
            colors: [
              colors.brand,
              Color.lerp(colors.brand, Colors.black, 0.35)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.vertical(top: corner),
              child: Padding(
                padding: EdgeInsets.all(m.walletHPad),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppSvgImages.wallet,
                                width: m.walletLabelSize,
                                height: m.walletLabelSize,
                                colorFilter: ColorFilter.mode(
                                  muted,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: m.gapXs * 1.5),
                              _label('BiGod Wallet', muted, m),
                            ],
                          ),
                          SizedBox(height: m.gapXs * 1.5),
                          Text(
                            formattedBalance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: colors.onBrand,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: m.walletBalanceSize * 1.25,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: m.gapSm),
                    _Pill(icon: Icons.add_rounded, label: 'Add', metrics: m),
                  ],
                ),
              ),
            ),
            tvs,
          ],
        ),
      ),
    );
  }
}

Text _label(String text, Color color, ProfileMetrics m) => Text(
  text,
  style: AppTextStyles.labelMedium.copyWith(
    color: color,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    fontSize: m.walletLabelSize * 0.85,
  ),
);

// White pill on the wallet card; the row it sits in handles the tap.
class _Pill extends StatelessWidget {
  final IconData? icon;
  final String label;
  final ProfileMetrics metrics;

  const _Pill({this.icon, required this.label, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = metrics;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.walletHPad * 0.8,
        vertical: m.gapXs * 1.6,
      ),
      decoration: BoxDecoration(
        color: colors.onBrand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: m.walletLabelSize, color: colors.brand),
            SizedBox(width: m.gapXs * 0.5),
          ],
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: colors.brand,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.walletLabelSize * 0.85,
            ),
          ),
        ],
      ),
    );
  }
}

// The home TVS Wallet: its coins and what they're worth (1 TVS Coin = 1 unit
// of the wallet's currency); tap for the full wallet. Hidden when the wallet
// can't be loaded.
class _TvsWalletRow extends StatefulWidget {
  final ProfileEntity profile; // a new object each time the profile reloads
  final ProfileMetrics metrics;

  const _TvsWalletRow({required this.profile, required this.metrics});

  @override
  State<_TvsWalletRow> createState() => _TvsWalletRowState();
}

class _TvsWalletRowState extends State<_TvsWalletRow> {
  final _api = getIt<TvsQrDataSource>();
  late Future<Map<String, dynamic>> _summary = _api.walletSummary();

  @override
  void didUpdateWidget(_TvsWalletRow old) {
    super.didUpdateWidget(old);
    // Pull-to-refresh reloads the profile; reload the wallet with it.
    if (!identical(old.profile, widget.profile)) {
      _summary = _api.walletSummary();
    }
  }

  // Amounts are strings with 2 decimals; added in cents to stay exact.
  static String _sum(String a, String b) {
    final cents =
        int.parse(a.replaceAll('.', '')) + int.parse(b.replaceAll('.', ''));
    return '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
  }

  // The full wallet (it also has activation); its balance may change there.
  void _open() {
    context.push(AppRoutes.tvsWallet).then((_) {
      if (mounted) setState(() => _summary = _api.walletSummary());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = widget.metrics;
    final muted = colors.onBrand.withValues(alpha: 0.75);

    return FutureBuilder<Map<String, dynamic>>(
      future: _summary,
      builder: (context, snap) {
        final wallets = snap.data?['wallets'] as List?;
        if (snap.hasError || (snap.hasData && (wallets?.isEmpty ?? true))) {
          return const SizedBox.shrink();
        }
        final w = wallets?.first as Map<String, dynamic>?;
        final activate = snap.data?['activationRequired'] == true;
        final total = w == null
            ? ''
            : _sum('${w['available']}', '${w['bonus']}');

        final big = AppTextStyles.titleLarge.copyWith(
          color: colors.onBrand,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: m.walletBalanceSize,
          height: 1.1,
        );
        final small = AppTextStyles.bodySmall.copyWith(
          color: muted,
          fontFamily: 'Inter',
          fontSize: m.walletLabelSize * 0.8,
        );

        return Column(
          children: [
            Divider(
              height: 1,
              thickness: 1,
              indent: m.walletHPad,
              endIndent: m.walletHPad,
              color: colors.onBrand.withValues(alpha: 0.15),
            ),
            InkWell(
              onTap: _open,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(m.walletRadius + 6),
              ),
              child: Padding(
                padding: EdgeInsets.all(m.walletHPad),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.toll_rounded,
                                size: m.walletLabelSize,
                                color: muted,
                              ),
                              SizedBox(width: m.gapXs * 1.5),
                              _label('TVS Wallet', muted, m),
                            ],
                          ),
                          SizedBox(height: m.gapXs * 1.5),
                          if (w == null)
                            // Opaque tints: the shimmer paints over the box.
                            ShimmerLoading(
                              baseColor: Color.lerp(
                                colors.brand,
                                colors.onBrand,
                                0.2,
                              ),
                              highlightColor: Color.lerp(
                                colors.brand,
                                colors.onBrand,
                                0.45,
                              ),
                              child: Container(
                                width: 140,
                                height: m.walletBalanceSize,
                                decoration: BoxDecoration(
                                  color: colors.onBrand,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            )
                          else ...[
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: total, style: big),
                                  TextSpan(text: ' TVS Coins', style: small),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: m.gapXs * 0.6),
                            Text('Worth $total ${w['currency']}', style: small),
                          ],
                        ],
                      ),
                    ),
                    if (activate) ...[
                      SizedBox(width: m.gapSm),
                      _Pill(label: 'Activate', metrics: m),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
