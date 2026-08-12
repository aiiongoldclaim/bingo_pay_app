// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/widgets/app_icon_container.dart';
//
// class HomeHeader extends StatelessWidget {
//   const HomeHeader({super.key, required this.userName});
//
//   final String userName;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 6.h, bottom: 2.h),
//       child: Row(
//         children: [
//           AppIconContainer(
//             size: 13.w,
//             text: userName.isNotEmpty ? userName[0].toUpperCase() : "A",
//           ),
//
//           SizedBox(width: 3.w),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Good morning,",
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontFamily: "Inter",
//                     fontWeight: FontWeight.w400,
//                     color: ThemeColors.white,
//                   ),
//                 ),
//                 Text(
//                   userName,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontFamily: "Inter",
//                     fontWeight: FontWeight.w600,
//                     color: ThemeColors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           AppIconContainer(
//             icon: Icons.notifications_none,
//             onTap: () {
//               final bottomPadding = MediaQuery.of(context).padding.bottom;
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Notification feature coming soon'),
//                   // ⭐ THIS LINE FIXES YOUR ERROR
//                   behavior: SnackBarBehavior.floating,
//                   margin: EdgeInsets.fromLTRB(
//                     10,
//                     0,
//                     10,
//                     kBottomNavigationBarHeight - 2.h, // ⭐ pushes above FAB
//                   ),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'home_metrics.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.metrics,
    required this.brandName,
    this.cartCount = 0,
    this.onMenuTap,
    this.onWishlistTap,
    this.onCartTap,
  });

  final HomeMetrics metrics;
  final String brandName;
  final int cartCount;
  final VoidCallback? onMenuTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return SizedBox(
      height: metrics.headerHeight,
      child: Row(
        children: [
          _HeaderIcon(
            icon: Icons.menu_rounded,
            size: metrics.headerIconSize,
            color: c.textPrimary,
            onTap: onMenuTap,
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  brandName,
                  style: AppTextStyles.brandLogo.copyWith(
                    fontSize: metrics.logoSize,
                    color: c.brand,
                  ),
                ),
              ),
            ),
          ),
          _HeaderIcon(
            icon: Icons.favorite_border_rounded,
            size: metrics.headerIconSize,
            color: c.textPrimary,
            onTap: onWishlistTap,
          ),
          SizedBox(width: metrics.pagePadding * 0.9),
          _HeaderIcon(
            icon: Icons.shopping_bag_outlined,
            size: metrics.headerIconSize,
            color: c.textPrimary,
            badgeCount: cartCount,
            badgeColor: c.brand,
            onTap: onCartTap,
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.size,
    required this.color,
    this.onTap,
    this.badgeCount = 0,
    this.badgeColor,
  });

  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onTap;
  final int badgeCount;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: size, color: color),
          if (badgeCount > 0)
            Positioned(
              top: -size * 0.28,
              right: -size * 0.28,
              child: Container(
                width: size * 0.62,
                height: size * 0.62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
