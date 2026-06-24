import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../constants/app_sizes.dart';
import '../theme/theme_colors.dart';

class QrFab extends StatelessWidget {
  const QrFab({super.key, this.selected = false, this.onTap});

  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
            const BoxShadow(
              color: ThemeColors.white,
              blurRadius: 0,
              spreadRadius: 3,
            ),
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
