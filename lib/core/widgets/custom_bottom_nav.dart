import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key, this.currentIndex = 0, this.onTap});

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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        height: 10.h,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: selected ? ThemeColors.blueSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 25.sp,
                  color: selected ? ThemeColors.blue : ThemeColors.inkMid,
                ),

                SizedBox(height: 0.4.h),

                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected ? ThemeColors.blue : ThemeColors.inkMid,
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
