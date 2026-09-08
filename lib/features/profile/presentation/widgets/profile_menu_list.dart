import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/svg_image.dart';
import '../../../../core/router/app_routes.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theme/app_theme_colors.dart';

import 'profile_metrics.dart';

class ProfileMenuList extends StatelessWidget {
  final List<ProfileMenuItem> items;
  final void Function(ProfileMenuItem) onTap;

  const ProfileMenuList({super.key, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = ProfileMetrics.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: m.pageHPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.menuRadius),
        border: Border.all(color: colors.border),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.03),
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
                  color: colors.border,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final ProfileMenuItem item;
  final ProfileMetrics metrics;
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

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
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
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  item.icon,
                  size: m.menuIconSize,
                  color: colors.brand,
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
                        color: colors.textPrimary,
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
                        color: colors.textSecondary,
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
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuItem {
  final String title;
  final String subtitle;
  final String iconAsset;
  final String route;

  const ProfileMenuItem({
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
  static const List<ProfileMenuItem> primaryItems = [
    ProfileMenuItem(
      title: 'My Cart',
      subtitle: 'View and manage your cart',
      iconAsset: 'cart',
      route: AppRoutes.cart,
    ),
    ProfileMenuItem(
      title: 'Transactions',
      subtitle: 'View your order history',
      iconAsset: 'transactions',
      route: AppRoutes.buyerTransactions,
    ),
    ProfileMenuItem(
      title: 'Wishlist',
      subtitle: 'Your saved styles',
      iconAsset: 'wishlist',
      route: AppRoutes.buyerWishlist,
    ),
    ProfileMenuItem(
      title: 'My Bookings',
      subtitle: 'Manage your bookings',
      iconAsset: 'bookings',
      route: AppRoutes.myBookings,
    ),
  ];

  /// Group 2 — profile
  static const List<ProfileMenuItem> secondaryItems = [
    ProfileMenuItem(
      title: 'Help & Support',
      subtitle: 'Get help, track orders & more',
      iconAsset: 'help',
      route: AppRoutes.help,
    ),
    ProfileMenuItem(
      title: 'Edit Profile',
      subtitle: 'Update your personal details',
      iconAsset: 'editProfile',
      route: AppRoutes.editProfile,
    ),
    ProfileMenuItem(
      title: 'Membership',
      subtitle: 'Explore plans & benefits',
      iconAsset: 'membership',
      route: AppRoutes.membershipPlans,
    ),
    ProfileMenuItem(
      title: 'My Membership',
      subtitle: 'View your active plan',
      iconAsset: 'myMembership',
      route: AppRoutes.membership,
    ),
  ];

  static const List<ProfileMenuItem> items = [
    ...primaryItems,
    ...secondaryItems,
  ];
}
