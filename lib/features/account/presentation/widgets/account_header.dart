import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/enities/account_entity.dart';

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
    final actualBalance = value / 100000000; // 10^8
    return actualBalance.toStringAsFixed(8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: ThemeColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusMd),
          bottomRight: Radius.circular(AppSizes.radiusMd),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AppBarRow(title: 'Account', onEdit: onEdit),
            SizedBox(height: .5.h),

            _AvatarRow(account: account),

            SizedBox(height: 2.5.h),

            _StatRow(
              account: account,
              formattedBalance: _formatBalance(account.displayBigoldBalance),
              onWalletTap: onWalletTap,
            ),

            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}

class _AppBarRow extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;

  const _AppBarRow({required this.title, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              color: ThemeColors.white,
              fontSize: 22.sp,
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: ThemeColors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.mode_edit_outline_outlined,
                color: ThemeColors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  final AccountEntity account;

  const _AvatarRow({required this.account});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: ThemeColors.white.withOpacity(.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            alignment: Alignment.center,
            child:
                account.profileImageUrl != null &&
                    account.profileImageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: Image.network(
                      account.profileImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    account.initials,
                    style: TextStyle(
                      color: ThemeColors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),

          SizedBox(width: 4.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.fullName,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: ThemeColors.white,
                    fontSize: 18.sp,
                  ),
                ),

                Text(
                  account.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: ThemeColors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .8.h),
            decoration: BoxDecoration(
              color: ThemeColors.accent,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              account.kycStatus.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: ThemeColors.accentInk,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final AccountEntity account;
  final String formattedBalance;
  final VoidCallback onWalletTap;

  const _StatRow({
    required this.account,
    required this.formattedBalance,
    required this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 11.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Row(
          children: [
            GestureDetector(
              onTap: onWalletTap,
              child: _StatTile(value: formattedBalance, label: "BiGold"),
            ),

            SizedBox(width: 3.w),

            _StatTile(
              value: account.usdtBalance.toStringAsFixed(2),
              label: "USDT",
            ),

            SizedBox(width: 3.w),

            _StatTile(
              value: account.referralCode.toString(),
              label: "Referral",
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 28.w, maxWidth: 60.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: ThemeColors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  color: ThemeColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.sp,
                ),
              ),
            ),

            SizedBox(height: .5.h),

            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: ThemeColors.white.withOpacity(.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
