// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import '../../../../../core/theme/theme_colors.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../../../core/constants/app_sizes.dart';
// import '../../domain/enities/account_entity.dart';
//
// class AccountHeader extends StatelessWidget {
//   final AccountEntity account;
//   final VoidCallback onEdit;
//   final VoidCallback onWalletTap;
//
//   const AccountHeader({
//     super.key,
//     required this.account,
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
//     return Container(
//       decoration: BoxDecoration(
//         gradient: ThemeColors.buttonBackGroundColor,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(AppSizes.radiusMd),
//           bottomRight: Radius.circular(AppSizes.radiusMd),
//         ),
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             _AppBarRow(title: 'Profile', onEdit: onEdit),
//             SizedBox(height: .1.h),
//
//             _AvatarRow(account: account),
//
//             SizedBox(height: 2.5.h),
//
//             _WalletCard(
//               formattedBalance: _formatBalance(account.displayBigoldBalance),
//               // onTap: onWalletTap,
//               onTap: () {},
//             ),
//
//             SizedBox(height: 3.h),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _AppBarRow extends StatelessWidget {
//   final String title;
//   final VoidCallback onEdit;
//
//   const _AppBarRow({required this.title, required this.onEdit});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
//       child: Row(
//         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: AppTextStyles.titleLarge.copyWith(
//               color: ThemeColors.black,
//               fontSize: 22.sp,
//             ),
//           ),
//           Spacer(),
//
//           // GestureDetector(
//           //   onTap: onEdit,
//           //   child: Container(
//           //     width: 12.w,
//           //     height: 12.w,
//           //     decoration: BoxDecoration(
//           //       color: ThemeColors.white.withOpacity(0.15),
//           //       borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//           //     ),
//           //     alignment: Alignment.center,
//           //     child: Icon(
//           //       Icons.mode_edit_outline_outlined,
//           //       color: ThemeColors.white,
//           //       size: 20.sp,
//           //     ),
//           //   ),
//           IconButton(
//             color: ThemeColors.black,
//             icon: const Icon(Icons.settings),
//             onPressed: () {},
//           ),
//           IconButton(
//             color: ThemeColors.black,
//             icon: const Icon(Icons.notifications),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _AvatarRow extends StatelessWidget {
//   final AccountEntity account;
//
//   const _AvatarRow({required this.account});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 5.w),
//       child: Row(
//         children: [
//           Container(
//             width: 14.w,
//             height: 14.w,
//             decoration: BoxDecoration(
//               color: ThemeColors.white.withOpacity(.2),
//               borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//             ),
//             alignment: Alignment.center,
//             child:
//                 account.profileImageUrl != null &&
//                     account.profileImageUrl!.isNotEmpty
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//                     child: Image.network(
//                       account.profileImageUrl!,
//                       fit: BoxFit.cover,
//                     ),
//                   )
//                 : Text(
//                     account.initials,
//                     style: TextStyle(
//                       color: ThemeColors.white,
//                       fontSize: 20.sp,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//           ),
//
//           SizedBox(width: 4.w),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   account.fullName,
//                   style: AppTextStyles.titleLarge.copyWith(
//                     color: ThemeColors.white,
//                     fontSize: 18.sp,
//                   ),
//                 ),
//
//                 Text(
//                   account.email,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: ThemeColors.white,
//                     fontSize: 14.sp,
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
//   final VoidCallback onTap;
//
//   const _WalletCard({required this.formattedBalance, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 5.w),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
//           decoration: BoxDecoration(
//             color: ThemeColors.white.withValues(alpha: 0.13),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: ThemeColors.white.withValues(alpha: 0.22),
//               width: 1,
//             ),
//           ),
//           child: Row(
//             children: [
//               // Coin icon
//               Icon(
//                 Icons.account_balance_wallet,
//                 color: ThemeColors.purple,
//                 size: 20.sp,
//               ),
//
//               SizedBox(width: 3.5.w),
//
//               // Label + balance
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Bingold Wallet',
//                       style: AppTextStyles.labelMedium.copyWith(
//                         color: ThemeColors.white.withValues(alpha: 0.7),
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                     SizedBox(height: 0.4.h),
//                     Text(
//                       '$formattedBalance USDT',
//                       style: AppTextStyles.titleMedium.copyWith(
//                         color: ThemeColors.white,
//                         fontWeight: FontWeight.w800,
//                         fontSize: 15.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Tap indicator
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: ThemeColors.white.withValues(alpha: 0.12),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   color: ThemeColors.white,
//                   size: 12.sp,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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
              onPressed: onSettingsTap ?? () {},
            ),
          ],
        ),
        // Stack(
        //   clipBehavior: Clip.none,
        //   alignment: Alignment.center,
        //   children: [
        //     IconButton(
        //       splashRadius: m.appBarIconSize * 1.2,
        //       icon: SvgPicture.asset(
        //         AppSvgImages.notification,
        //         width: m.appBarIconSize,
        //         height: m.appBarIconSize,
        //         colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
        //       ),
        //       onPressed: onNotificationTap ?? () {},
        //     ),
        //     Positioned(
        //       right: m.appBarIconSize * 0.42,
        //       top: m.appBarIconSize * 0.40,
        //       child: Container(
        //         width: m.appBarIconSize * 0.30,
        //         height: m.appBarIconSize * 0.30,
        //         decoration: BoxDecoration(
        //           color: c.brand,
        //           shape: BoxShape.circle,
        //           border: Border.all(color: c.surfaceAlt, width: 1.5),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(width: m.appBarHPad * 0.4),
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
            width: m.avatarSize + m.cameraBadgeSize * 0.30,
            height: m.avatarSize + m.cameraBadgeSize * 0.20,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: m.avatarSize,
                  height: m.avatarSize,
                  decoration: BoxDecoration(
                    color: c.brand,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surface, width: 3),
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
                      : Text(
                          account.initials,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: ThemeColors.white,
                            fontFamily: 'Inter',
                            fontSize: m.avatarInitialSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: m.cameraBadgeSize,
                      height: m.cameraBadgeSize,
                      decoration: BoxDecoration(
                        color: c.textSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.surface, width: 2),
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
