import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/theme_colors.dart';
import '../constants/app_sizes.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key, this.currentIndex = 0, this.onTap});

  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Glass panel ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeColors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: ThemeColors.white.withOpacity(0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColors.blue.withOpacity(0.10),
                      blurRadius: AppSizes.shadowBlurLg,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: ThemeColors.black.withOpacity(0.06),
                      blurRadius: AppSizes.shadowBlurMd,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      outlinedIcon: Icons.home_outlined,
                      label: 'Home',
                      selected: currentIndex == 0,
                      onTap: () => onTap?.call(0),
                    ),
                    _NavItem(
                      icon: Icons.grid_view_rounded,
                      outlinedIcon: Icons.grid_view_outlined,
                      label: 'Categories',
                      selected: currentIndex == 1,
                      onTap: () => onTap?.call(1),
                    ),
                    // Centre gap for the QR button
                    SizedBox(width: 18.w),
                    _NavItem(
                      icon: Icons.add_shopping_cart,
                      outlinedIcon: Icons.add_shopping_cart,
                      label: 'Order',
                      selected: currentIndex == 3,
                      badgeCount: 3,
                      onTap: () => onTap?.call(3),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      outlinedIcon: Icons.person_outline_rounded,
                      label: 'Account',
                      selected: currentIndex == 4,
                      onTap: () => onTap?.call(4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating QR centre button ─────────────────────────────
          Positioned(
            top: -3.2.h,
            child: _CentreButton(
              selected: currentIndex == 2,
              onTap: () => onTap?.call(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav item ──────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pill + icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 3.w : 2.w,
                  vertical: 1.h,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? ThemeColors.blue.withOpacity(0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedScale(
                      scale: selected ? 1.5 : 1.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        selected ? icon : outlinedIcon,
                        size: AppSizes.iconMd,
                        color: selected ? ThemeColors.blue : ThemeColors.inkDim,
                      ),
                    ),
                    // if (badgeCount != null && badgeCount! > 0)
                    //   Positioned(
                    //     top: -0.6.h,
                    //     right: -1.5.w,
                    //     child: _Badge(count: badgeCount!),
                    //   ),
                  ],
                ),
              ),
              SizedBox(height: 0.4.h),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: selected ? 14.sp : 13.sp,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? ThemeColors.blue : ThemeColors.inkDim,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.1,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Centre QR button ──────────────────────────────────────────────────────

class _CentreButton extends StatelessWidget {
  const _CentreButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Button size derived from bar height so it scales with screen
    final size = 14.w;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          gradient: ThemeColors.primaryGradient,
          boxShadow: [
            // White ring
            const BoxShadow(
              color: ThemeColors.white,
              blurRadius: 0,
              spreadRadius: 3,
            ),
            // Blue glow
            BoxShadow(
              color: ThemeColors.blue.withOpacity(selected ? 0.55 : 0.30),
              blurRadius: selected ? 24 : 14,
              spreadRadius: selected ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedScale(
            scale: selected ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 220),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: ThemeColors.white,
              size: AppSizes.iconMd,
            ),
          ),
        ),
      ),
    );
  }
}
