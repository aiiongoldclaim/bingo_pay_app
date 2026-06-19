// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../theme/theme_colors.dart';
//
// class AppBottomNavigation extends StatelessWidget {
//   const AppBottomNavigation({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//     this.cartCount = 0,
//   });
//
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//   final int cartCount;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 10.h,
//       decoration: const BoxDecoration(
//         color: ThemeColors.surface2,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(28),
//           topRight: Radius.circular(28),
//         ),
//       ),
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.topCenter,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _NavItem(
//                   icon: Icons.home_outlined,
//                   label: 'Home',
//                   selected: currentIndex == 0,
//                   onTap: () => onTap(0),
//                 ),
//               ),
//
//               Expanded(
//                 child: _NavItem(
//                   icon: Icons.grid_view_rounded,
//                   label: 'Categories',
//                   selected: currentIndex == 1,
//                   onTap: () => onTap(1),
//                 ),
//               ),
//
//               SizedBox(width: 22.w),
//
//               Expanded(
//                 child: _NavItem(
//                   icon: Icons.shopping_bag_outlined,
//                   label: 'Cart',
//                   badgeCount: cartCount,
//                   selected: currentIndex == 3,
//                   onTap: () => onTap(3),
//                 ),
//               ),
//
//               Expanded(
//                 child: _NavItem(
//                   icon: Icons.person_outline,
//                   label: 'Account',
//                   selected: currentIndex == 4,
//                   onTap: () => onTap(4),
//                 ),
//               ),
//             ],
//           ),
//
//           Positioned(
//             top: -3.h,
//             child: GestureDetector(
//               onTap: () => onTap(2),
//               child: Container(
//                 width: 17.w,
//                 height: 17.w,
//                 decoration: BoxDecoration(
//                   color: ThemeColors.white,
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: [
//                     BoxShadow(
//                       color: ThemeColors.blue.withOpacity(.20),
//                       blurRadius: 20,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(5),
//                   decoration: BoxDecoration(
//                     gradient: ThemeColors.primaryGradient,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Icon(
//                     Icons.qr_code_scanner_rounded,
//                     color: ThemeColors.white,
//                     size: 21.sp,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _NavItem extends StatelessWidget {
//   const _NavItem({
//     required this.icon,
//     required this.label,
//     required this.selected,
//     required this.onTap,
//     this.badgeCount = 0,
//   });
//
//   final IconData icon;
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;
//   final int badgeCount;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: SizedBox(
//         height: 10.h,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Icon(
//                   icon,
//                   size: 22.sp,
//                   color: selected ? ThemeColors.blue : ThemeColors.inkDim,
//                 ),
//
//                 if (badgeCount > 0)
//                   Positioned(
//                     right: -10,
//                     top: -8,
//                     child: Container(
//                       width: 5.w,
//                       height: 5.w,
//                       decoration: const BoxDecoration(
//                         color: ThemeColors.accent,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Text(
//                           badgeCount.toString(),
//                           style: TextStyle(
//                             fontSize: 7.sp,
//                             fontWeight: FontWeight.w700,
//                             color: ThemeColors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//
//             SizedBox(height: .5.h),
//
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 9.sp,
//                 fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
//                 color: selected ? ThemeColors.blue : ThemeColors.inkDim,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
