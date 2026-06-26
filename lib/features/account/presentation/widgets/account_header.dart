import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
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
    String s = value.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
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

            _WalletCard(
              formattedBalance: _formatBalance(account.displayBigoldBalance),
              onTap: onWalletTap,
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
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final String formattedBalance;
  final VoidCallback onTap;

  const _WalletCard({required this.formattedBalance, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
          decoration: BoxDecoration(
            color: ThemeColors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ThemeColors.white.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Coin icon
              Container(
                width: 11.w,
                height: 11.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.toll_rounded,
                  color: const Color(0xFFFFD700),
                  size: 20.sp,
                ),
              ),

              SizedBox(width: 3.5.w),

              // Label + balance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bingold Wallet',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: ThemeColors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      '$formattedBalance USDT',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: ThemeColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Tap indicator
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ThemeColors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ThemeColors.white,
                  size: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
