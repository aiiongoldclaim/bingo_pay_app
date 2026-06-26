import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';

class AccountMenuList extends StatelessWidget {
  final List<AccountMenuItem> items;
  final void Function(AccountMenuItem) onTap;

  const AccountMenuList({super.key, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.ink.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              _MenuItem(item: item, onTap: () => onTap(item)),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 16.w,
                  endIndent: 4.w,
                  color: ThemeColors.line,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final AccountMenuItem item;
  final VoidCallback onTap;

  const _MenuItem({required this.item, required this.onTap});

  IconData _iconFor(String key) {
    switch (key) {
      case 'cart':
        return Icons.shopping_cart_outlined;
      case 'orders':
        return Icons.inventory_2_outlined;
      case 'wishlist':
        return Icons.favorite_border_rounded;
      case 'addresses':
        return Icons.location_on_outlined;
      case 'payments':
        return Icons.credit_card_outlined;
      case 'coupons':
        return Icons.percent_rounded;
      case 'help':
        return Icons.headset_mic_outlined;
      default:
        return Icons.chevron_right;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: ThemeColors.blueSoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              alignment: Alignment.center,
              child: Icon(
                _iconFor(item.iconAsset),
                color: ThemeColors.blue,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 4.w),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: ThemeColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 0.1.h),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: ThemeColors.inkMid,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: ThemeColors.inkDim, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class AccountMenuItem {
  final String title;
  final String subtitle;
  final String iconAsset;
  final String route;

  const AccountMenuItem({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.route,
  });

  static const List<AccountMenuItem> items = [
    AccountMenuItem(
      title: 'My Cart',
      subtitle: 'View & manage your cart',
      iconAsset: 'cart',
      route: AppRoutes.cart,
    ),

    AccountMenuItem(
      title: 'My Orders',
      subtitle: 'Track, return or buy again',
      iconAsset: 'orders',
      route: AppRoutes.orders,
    ),

    AccountMenuItem(
      title: 'Wishlist',
      subtitle: '24 saved items',
      iconAsset: 'wishlist',
      route: '/wishlist',
    ),

    // AccountMenuItem(
    //   title: 'Addresses',
    //   subtitle: '2 saved',
    //   iconAsset: 'addresses',
    //   route: '/addresses',
    // ),

    // AccountMenuItem(
    //   title: 'Payment Methods',
    //   subtitle: 'UPI, cards & wallet',
    //   iconAsset: 'payments',
    //   route: '/payments',
    // ),

    // AccountMenuItem(
    //   title: 'Coupons & Offers',
    //   subtitle: '5 available',
    //   iconAsset: 'coupons',
    //   route: '/coupons',
    // ),

    AccountMenuItem(
      title: 'Help & Support',
      subtitle: 'FAQs, chat with us',
      iconAsset: 'help',
      route: '/help',
    ),
  ];
}
