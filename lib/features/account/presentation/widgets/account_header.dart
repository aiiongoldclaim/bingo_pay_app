import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/svg_image.dart';
import '../../domain/enities/account_entity.dart';
import 'account_metrics.dart';

class AccountAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;

  const AccountAppBar({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = AccountMetrics.of(context);

    return AppBar(
      backgroundColor: c.surfaceAlt,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight + 8,
      titleSpacing: m.appBarHPad,
      title: Text(
        'Profile',
        style: AppTextStyles.titleLarge.copyWith(
          color: c.textPrimary,
          fontFamily: 'CormorantGaramond',
          fontWeight: FontWeight.w700,
          fontSize: m.titleSize,
          height: 1.1,
        ),
      ),
      actions: [
        Row(
          children: [
            IconButton(
              splashRadius: m.appBarIconSize * 1.2,
              icon: Icon(
                Icons.settings,
                size: m.appBarIconSize,
                color: c.textPrimary,
              ),
              onPressed: onSettingsTap ?? () {},
            ),
            IconButton(
              splashRadius: m.appBarIconSize * 1.2,
              icon: Icon(
                Icons.notifications_none_outlined,
                size: m.appBarIconSize,
                color: c.textPrimary,
              ),
              onPressed: onNotificationTap ?? () {},
            ),
          ],
        ),

      ],
    );
  }
}

class AccountHeader extends StatelessWidget {
  final AccountEntity account;
  final VoidCallback onEdit;
  final VoidCallback onWalletTap;

  const AccountHeader({
    super.key,
    required this.account,
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
    final c = context.c;
    final m = AccountMetrics.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(m.menuRadius + 8),
          bottomRight: Radius.circular(m.menuRadius + 8),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: m.gapSm),
              _AvatarRow(account: account, metrics: m, onEdit: onEdit),
              SizedBox(height: m.gapMd),
              _WalletCard(
                formattedBalance: _formatBalance(account.displayBigoldBalance),
                metrics: m,
                onTap: onWalletTap,
              ),
              SizedBox(height: m.gapMd),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  final AccountEntity account;
  final AccountMetrics metrics;
  final VoidCallback onEdit;

  const _AvatarRow({
    required this.account,
    required this.metrics,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final hasImage =
        account.profileImageUrl != null && account.profileImageUrl!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
      child: Row(
        children: [
          SizedBox(
            width: m.avatarSize + m.cameraBadgeSize * 0.35,
            height: m.avatarSize + m.cameraBadgeSize * 0.20,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: m.avatarSize,
                  height: m.avatarSize,
                  decoration: BoxDecoration(
                    color: c.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c.brand.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: hasImage
                      ? ClipOval(
                    child: Image.network(
                      account.profileImageUrl!,
                      width: m.avatarSize,
                      height: m.avatarSize,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(
                    Icons.person,
                    size: m.avatarSize * 0.55,
                    color: c.brand,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: m.avatarSize * 0.06,
                  child: GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: m.cameraBadgeSize,
                      height: m.cameraBadgeSize,
                      decoration: BoxDecoration(
                        color: c.textSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.surfaceAlt, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.photo_camera_rounded,
                        size: m.cameraIconSize,
                        color: c.surface,
                      ),
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
                Text(
                  account.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.nameSize,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: m.gapXs),
                Text(
                  account.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: m.emailSize,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final String formattedBalance;
  final AccountMetrics metrics;
  final VoidCallback onTap;

  const _WalletCard({
    required this.formattedBalance,
    required this.metrics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(m.walletRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: m.walletHPad * 0.85,
              vertical: m.walletVPad * 0.6,
            ),
            decoration: BoxDecoration(
              color: c.brandSoft,
              borderRadius: BorderRadius.circular(m.walletRadius),
              border: Border.all(color: c.border, width: 1),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppSvgImages.wallet,
                  width: m.walletIconSize * 0.8,
                  height: m.walletIconSize * 0.8,
                  colorFilter: ColorFilter.mode(c.brand, BlendMode.srcIn),
                ),

                SizedBox(width: m.walletGap * 0.8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bingold Wallet',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: c.textPrimary,
                          fontFamily: 'Inter',
                          fontSize: m.walletLabelSize * 0.9,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        '\$ $formattedBalance',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: c.brand,
                          fontFamily: 'Inter',
                          fontSize: m.walletBalanceSize * 0.9,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
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
