
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/svg_image.dart';
import '../../../../core/router/app_routes.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theme/app_theme_colors.dart';

import 'account_metrics.dart';

class AccountMenuList extends StatelessWidget {
  final List<AccountMenuItem> items;
  final void Function(AccountMenuItem) onTap;

  const AccountMenuList({super.key, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = AccountMetrics.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: m.pageHPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.menuRadius),
        boxShadow: c.isDark
            ? null
            : [
          BoxShadow(
            color: c.textPrimary.withValues(alpha: 0.03),
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
              _MenuItem(
                item: item,
                metrics: m,
                isFirst: index == 0,
                isLast: isLast,
                onTap: () => onTap(item),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: m.dividerIndent,
                  endIndent: m.menuItemHPad,
                  color: c.border,
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
  final AccountMetrics metrics;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _MenuItem({
    required this.item,
    required this.metrics,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  String _iconFor(String key) {
    switch (key) {
      case 'cart':
        return AppSvgImages.cart;
      case 'orders':
      case 'transactions':
        return AppSvgImages.transactions;
      case 'wishlist':
        return AppSvgImages.wishlist;
      case 'addresses':
      case 'profile':
        return AppSvgImages.profile;
      case 'payments':
        return AppSvgImages.securePayments;
      case 'editProfile':
        return AppSvgImages.editProfile;
      case 'memberShip':
        return AppSvgImages.easyReturns;
      case 'memberShip':
        return AppSvgImages.easyReturns;
      case 'help':
        return AppSvgImages.support;
      default:
        return AppSvgImages.chevronRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirst ? m.menuRadius : 0),
          bottom: Radius.circular(isLast ? m.menuRadius : 0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: m.menuItemHPad,
            vertical: m.menuItemVPad,
          ),
          child: Row(
            children: [
              Container(
                width: m.menuIconBox,
                height: m.menuIconBox,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  item.icon,
                  size: m.menuIconSize,
                  color: c.brand,
                ),
              ),

              SizedBox(width: m.menuIconGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: m.menuTitleSize,
                      ),
                    ),
                    SizedBox(height: m.gapXs),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: m.menuSubtitleSize,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: m.gapSm),
              Icon(
                Icons.chevron_right_rounded,
                size: m.chevronSize + 6,
                color: c.textMuted,
              ),
            ],
          ),
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

  /// Single source of truth for menu icons.
  IconData get icon => iconFor(iconAsset);

  static IconData iconFor(String key) {
    switch (key) {
      case 'cart':
        return Icons.shopping_cart_outlined;
      case 'orders':
      case 'transactions':
        return Icons.receipt_long_outlined;
      case 'wishlist':
        return Icons.favorite_border_rounded;
      case 'bookings':
        return Icons.event_available_outlined;
      case 'addresses':
        return Icons.location_on_outlined;
      case 'profile':
        return Icons.person_outline_rounded;
      case 'editProfile':
        return Icons.manage_accounts_outlined;
      case 'membership':
        return Icons.workspace_premium_outlined;
      case 'myMembership':
        return Icons.card_membership_outlined;
      case 'payments':
        return Icons.credit_card_outlined;
      case 'help':
        return Icons.support_agent_outlined;
      case 'logout':
        return Icons.logout_rounded;
      default:
        return Icons.chevron_right_rounded;
    }
  }

  /// Group 1 — shopping
  static const List<AccountMenuItem> primaryItems = [
    AccountMenuItem(
      title: 'My Cart',
      subtitle: 'View and manage your cart',
      iconAsset: 'cart',
      route: AppRoutes.cart,
    ),
    AccountMenuItem(
      title: 'Transactions',
      subtitle: 'View your order history',
      iconAsset: 'transactions',
      route: AppRoutes.buyerTransactions,
    ),
    AccountMenuItem(
      title: 'Wishlist',
      subtitle: 'Your saved styles',
      iconAsset: 'wishlist',
      route: AppRoutes.buyerWishlist,
    ),
    AccountMenuItem(
      title: 'My Bookings',
      subtitle: 'Manage your bookings',
      iconAsset: 'bookings',            // pehle 'cart' tha → cart jaisa hi icon aa raha tha
      route: AppRoutes.myBookings,
    ),
  ];

  /// Group 2 — account
  static const List<AccountMenuItem> secondaryItems = [
    AccountMenuItem(
      title: 'Help & Support',
      subtitle: 'Get help, track orders & more',
      iconAsset: 'help',
      route: AppRoutes.help,
    ),
    AccountMenuItem(
      title: 'Edit Profile',
      subtitle: 'Update your personal details',
      iconAsset: 'editProfile',         // pehle 'profile' tha
      route: AppRoutes.editProfile,
    ),
    AccountMenuItem(
      title: 'Membership',
      subtitle: 'Explore plans & benefits',
      iconAsset: 'membership',
      route: AppRoutes.membershipPlans,
    ),
    AccountMenuItem(
      title: 'My Membership',
      subtitle: 'View your active plan',
      iconAsset: 'myMembership',        // key ab switch se match karti hai
      route: AppRoutes.membership,
    ),
  ];

  static const List<AccountMenuItem> items = [
    ...primaryItems,
    ...secondaryItems,
  ];
}
