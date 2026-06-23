import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

class GoldInvestBanner extends StatelessWidget {
  const GoldInvestBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
    this.leadingIcon,
    this.backgroundColor,
    this.buttonGradient,
    this.borderRadius,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  final Widget? leadingIcon;

  final Color? backgroundColor;

  final Gradient? buttonGradient;

  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSizes.radiusLg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeColors.accentSoft,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ThemeColors.accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          leadingIcon ?? _DefaultGoldIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: ThemeColors.accentInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: ThemeColors.accentInk.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _InvestButton(
            label: buttonLabel,
            gradient: buttonGradient ?? ThemeColors.goldGradient,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _DefaultGoldIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: ThemeColors.accent.withOpacity(0.18),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(Icons.toll_rounded, size: 18, color: ThemeColors.accent),
      ),
    );
  }
}

class _InvestButton extends StatelessWidget {
  const _InvestButton({
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: ThemeColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
