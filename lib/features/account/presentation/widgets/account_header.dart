import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/account_model/account_model.dart';

class AccountHeader extends StatelessWidget {
  final AccountModel account;
  final VoidCallback onEdit;
  final VoidCallback onWalletTap;

  const AccountHeader({
    super.key,
    required this.account,
    required this.onEdit,
    required this.onWalletTap,
  });

  String _formatBalance(double v) {
    final s = v.truncate().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      final rem = fromEnd - 1;
      if (rem == 3 || (rem > 3 && (rem - 3) % 2 == 0)) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: ThemeColors.primaryGradient,
        // color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AppBarRow(title: 'Account', onEdit: onEdit),
            SizedBox(height: 0.5.h),
            _AvatarRow(account: account),
            SizedBox(height: 2.5.h),
            _StatRow(
              account: account,
              formattedBalance: _formatBalance(account.walletBalance),
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
                borderRadius: BorderRadius.circular(12),
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
  final AccountModel account;
  const _AvatarRow({required this.account});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: ThemeColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: account.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(account.avatarUrl!),
                  )
                : Text(
                    account.initial,
                    style: TextStyle(
                      color: ThemeColors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          SizedBox(width: 4.w),
          // Name + email
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
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),
          // Membership badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: ThemeColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              account.membershipTier,
              style: AppTextStyles.labelMedium.copyWith(
                color: ThemeColors.accentInk,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final AccountModel account;
  final String formattedBalance;
  final VoidCallback onWalletTap;

  const _StatRow({
    required this.account,
    required this.formattedBalance,
    required this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onWalletTap,
              child: _StatTile(value: '₹$formattedBalance', label: 'Wallet'),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _StatTile(value: '${account.coins}', label: 'Coins'),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _StatTile(
              value: '${account.wishlistCount}',
              label: 'Wishlist',
            ),
          ),
        ],
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
      decoration: BoxDecoration(
        color: ThemeColors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: ThemeColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
            ),
          ),
          SizedBox(height: 0.1.h),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: ThemeColors.white.withOpacity(0.7),
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
