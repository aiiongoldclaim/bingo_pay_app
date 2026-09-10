// ─────────────────────────────────────────────────────────────────────────
// ORIGINAL — the profile avatar/wallet block (full-width strip, no verified
// badge, no chevron, no Top Up button), kept for reference. The redesigned
// version wraps everything in a single floating rounded card with a
// verified-user badge, a chevron affordance, and a Top Up button on the
// wallet row, matching the new mockup — see the active ProfileHeader
// implementation below.
// ─────────────────────────────────────────────────────────────────────────
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import '../../../../../core/theme/app_theme_colors.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../../../core/constants/svg_image.dart';
// import '../../domain/enities/profile_entity.dart';
// import 'profile_metrics.dart';
//
// class ProfileHeader extends StatelessWidget {
//   final ProfileEntity profile;
//   final VoidCallback onEdit;
//   final VoidCallback onWalletTap;
//
//   const ProfileHeader({
//     super.key,
//     required this.profile,
//     required this.onEdit,
//     required this.onWalletTap,
//   });
//
//   String _formatBalance(double value) {
//     String s = value.toStringAsFixed(8);
//     s = s.replaceAll(RegExp(r'0+$'), '');
//     s = s.replaceAll(RegExp(r'\.$'), '');
//     return s;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.c;
//     final m = ProfileMetrics.of(context);
//
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: colors.surfaceAlt,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(m.menuRadius + 8),
//           bottomRight: Radius.circular(m.menuRadius + 8),
//         ),
//       ),
//       child: Center(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxWidth: m.maxContentWidth),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               SizedBox(height: m.gapSm),
//               _AvatarRow(profile: profile, metrics: m, onEdit: onEdit),
//               SizedBox(height: m.gapMd),
//               _WalletCard(
//                 formattedBalance: _formatBalance(profile.displayBigoldBalance),
//                 metrics: m,
//                 onTap: onWalletTap,
//               ),
//               SizedBox(height: m.gapMd),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _AvatarRow extends StatelessWidget {
//   final ProfileEntity profile;
//   final ProfileMetrics metrics;
//   final VoidCallback onEdit;
//
//   const _AvatarRow({
//     required this.profile,
//     required this.metrics,
//     required this.onEdit,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.c;
//     final m = metrics;
//     final hasImage =
//         profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
//       child: Row(
//         children: [
//           SizedBox(
//             width: m.avatarSize + m.cameraBadgeSize * 0.35,
//             height: m.avatarSize + m.cameraBadgeSize * 0.20,
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   width: m.avatarSize,
//                   height: m.avatarSize,
//                   decoration: BoxDecoration(
//                     color: colors.surface,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: colors.brand.withValues(alpha: 0.25),
//                       width: 2,
//                     ),
//                   ),
//                   alignment: Alignment.center,
//                   child: hasImage
//                       ? ClipOval(
//                           child: Image.network(
//                             profile.profileImageUrl!,
//                             width: m.avatarSize,
//                             height: m.avatarSize,
//                             fit: BoxFit.cover,
//                           ),
//                         )
//                       : Icon(
//                           Icons.person,
//                           size: m.avatarSize * 0.55,
//                           color: colors.brand,
//                         ),
//                 ),
//                 Positioned(
//                   right: 0,
//                   bottom: m.avatarSize * 0.06,
//                   child: GestureDetector(
//                     onTap: onEdit,
//                     child: Container(
//                       width: m.cameraBadgeSize,
//                       height: m.cameraBadgeSize,
//                       decoration: BoxDecoration(
//                         color: colors.textSecondary,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: colors.surfaceAlt, width: 2),
//                       ),
//                       alignment: Alignment.center,
//                       child: Icon(
//                         Icons.photo_camera_rounded,
//                         size: m.cameraIconSize,
//                         color: colors.surface,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(width: m.avatarGap),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   profile.fullName,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTextStyles.titleLarge.copyWith(
//                     color: colors.textPrimary,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w700,
//                     fontSize: m.nameSize,
//                     height: 1.2,
//                   ),
//                 ),
//                 SizedBox(height: m.gapXs),
//                 Text(
//                   profile.email,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: colors.textSecondary,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w400,
//                     fontSize: m.emailSize,
//                     height: 1.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _WalletCard extends StatelessWidget {
//   final String formattedBalance;
//   final ProfileMetrics metrics;
//   final VoidCallback onTap;
//
//   const _WalletCard({
//     required this.formattedBalance,
//     required this.metrics,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.c;
//     final m = metrics;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(m.walletRadius),
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: m.walletHPad * 0.85,
//               vertical: m.walletVPad * 0.6,
//             ),
//             decoration: BoxDecoration(
//               color: colors.brandSoft,
//               borderRadius: BorderRadius.circular(m.walletRadius),
//               border: Border.all(color: colors.border, width: 1),
//             ),
//             child: Row(
//               children: [
//                 SvgPicture.asset(
//                   AppSvgImages.wallet,
//                   width: m.walletIconSize * 0.8,
//                   height: m.walletIconSize * 0.8,
//                   colorFilter: ColorFilter.mode(colors.brand, BlendMode.srcIn),
//                 ),
//
//                 SizedBox(width: m.walletGap * 0.8),
//
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Bingold Wallet',
//                         style: AppTextStyles.labelMedium.copyWith(
//                           color: colors.textPrimary,
//                           fontFamily: 'Inter',
//                           fontSize: m.walletLabelSize * 0.9,
//                           fontWeight: FontWeight.w500,
//                           height: 1.2,
//                         ),
//                       ),
//                       Text(
//                         '\$ $formattedBalance',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyles.titleMedium.copyWith(
//                           color: colors.brand,
//                           fontFamily: 'Inter',
//                           fontSize: m.walletBalanceSize * 0.9,
//                           fontWeight: FontWeight.w700,
//                           height: 1.2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/svg_image.dart';
import '../../domain/enities/profile_entity.dart';
import 'profile_metrics.dart';

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
    final colors = context.c;
    final m = ProfileMetrics.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: m.maxContentWidth),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: m.pageHPad),
          padding: EdgeInsets.all(m.pageHPad),
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: BorderRadius.circular(m.menuRadius + 6),
            boxShadow: colors.isDark
                ? null
                : [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AvatarRow(profile: profile, metrics: m, onEdit: onEdit),
              SizedBox(height: m.gapMd),
              _WalletCard(
                formattedBalance: _formatBalance(profile.displayBigoldBalance),
                metrics: m,
                onTap: onWalletTap,
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
    final colors = context.c;
    final m = metrics;
    final hasImage =
        profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty;
    final isVerified = profile.kycStatus.isVerified;

    return GestureDetector(
      onTap: onEdit,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    color: colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.brand.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: hasImage
                      ? ClipOval(
                          child: Image.network(
                            profile.profileImageUrl!,
                            width: m.avatarSize,
                            height: m.avatarSize,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: m.avatarSize * 0.55,
                          color: colors.brand,
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
                        color: colors.brand,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surfaceAlt, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.photo_camera_rounded,
                        size: m.cameraIconSize,
                        color: colors.onBrand,
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
                SizedBox(height: m.gapXs),
                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: m.emailSize,
                    height: 1.2,
                  ),
                ),
                if (isVerified) ...[
                  SizedBox(height: m.gapXs * 1.5),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: m.gapSm * 0.8,
                      vertical: m.gapXs * 0.6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brandSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          size: m.emailSize + 2,
                          color: colors.brand,
                        ),
                        SizedBox(width: m.gapXs),
                        Text(
                          'Verified User',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.brand,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: m.emailSize * 0.95,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
  final ProfileMetrics metrics;
  final VoidCallback onTap;

  const _WalletCard({
    required this.formattedBalance,
    required this.metrics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Material(
      color: colors.brandSoft,
      borderRadius: BorderRadius.circular(m.walletRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(m.walletRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: m.walletHPad * 0.85,
            vertical: m.walletVPad * 0.6,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                AppSvgImages.wallet,
                width: m.walletIconSize * 0.8,
                height: m.walletIconSize * 0.8,
                colorFilter: ColorFilter.mode(colors.brand, BlendMode.srcIn),
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
                        color: colors.textPrimary,
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
                        color: colors.brand,
                        fontFamily: 'Inter',
                        fontSize: m.walletBalanceSize * 0.9,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: m.walletGap * 0.5),

              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: m.walletHPad * 0.6,
                      vertical: m.gapXs * 1.4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brand,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: m.walletLabelSize,
                          color: colors.onBrand,
                        ),
                        SizedBox(width: m.gapXs * 0.5),
                        Text(
                          'ADD',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.onBrand,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: m.walletLabelSize * 0.85,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
