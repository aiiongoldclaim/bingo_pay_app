import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key, this.currentIndex = 0, this.onTap});

  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.h,
      decoration: const BoxDecoration(color: Color(0xFFF2F4FB)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  selected: currentIndex == 0,
                  onTap: () => onTap?.call(0),
                ),
              ),

              Expanded(
                child: _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Categories',
                  selected: currentIndex == 1,
                  onTap: () => onTap?.call(1),
                ),
              ),

              SizedBox(width: 22.w),

              Expanded(
                child: _NavItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Cart',
                  badgeCount: 3,
                  selected: currentIndex == 3,
                  onTap: () => onTap?.call(3),
                ),
              ),

              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline,
                  label: 'Account',
                  selected: currentIndex == 4,
                  onTap: () => onTap?.call(4),
                ),
              ),
            ],
          ),

          Positioned(
            top: -3.2.h,
            child: GestureDetector(
              onTap: () => onTap?.call(2),
              child: Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(.18),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2F5BFF), Color(0xFF1638B7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 10.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .9.h),
              decoration: selected
                  ? BoxDecoration(
                      color: ThemeColors.white,
                      borderRadius: BorderRadius.circular(30),
                    )
                  : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 23.sp,
                    color: selected ? ThemeColors.blue : ThemeColors.inkMid,
                  ),

                  // if (badgeCount != null)
                  //   Positioned(
                  //     right: -10,
                  //     top: -8,
                  //     child: Container(
                  //       width: 5.w,
                  //       height: 5.w,
                  //       decoration: const BoxDecoration(
                  //         color: Color(0xFFD4AF37),
                  //         shape: BoxShape.circle,
                  //       ),
                  //       child: Center(
                  //         child: Text(
                  //           badgeCount.toString(),
                  //           style: TextStyle(
                  //             fontSize: 7.sp,
                  //             fontWeight: FontWeight.w700,
                  //             color: Colors.black,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),

            // SizedBox(height: .4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? ThemeColors.blue : ThemeColors.inkMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
