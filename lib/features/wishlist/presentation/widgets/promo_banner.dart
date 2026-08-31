import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';


class AppPromoBanner extends StatelessWidget {
  const AppPromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.imagePath,
    required this.onPressed,
    this.fallbackIcon = Icons.favorite_rounded,
    this.padding,
    this.radius,
    this.titleSize,
    this.subtitleSize,
    this.buttonHeight,
    this.buttonFontSize,
    this.artSize,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final String imagePath;
  final VoidCallback onPressed;

  /// Image load na ho to yeh icon dikhega
  final IconData fallbackIcon;

  final double? padding;
  final double? radius;
  final double? titleSize;
  final double? subtitleSize;
  final double? buttonHeight;
  final double? buttonFontSize;
  final double? artSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final bannerPadding = padding ?? 4.w;
    final bannerRadius = radius ?? 4.w;
    final illustrationSize = artSize ?? 30.w;

    return Container(
      padding: EdgeInsets.all(bannerPadding),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(bannerRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize ?? 20.sp,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: bannerPadding * 0.4),

                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: subtitleSize ?? 13.sp,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: bannerPadding * 0.8),

                _PromoButton(
                  label: buttonLabel,
                  onPressed: onPressed,
                  height: buttonHeight ?? 5.h,
                  fontSize: buttonFontSize ?? 14.sp,
                  horizontalPadding: bannerPadding * 0.9,
                ),
              ],
            ),
          ),

          SizedBox(width: bannerPadding * 0.5),

          SizedBox(
            width: illustrationSize,
            height: illustrationSize,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                fallbackIcon,
                size: illustrationSize * 0.5,
                color: colors.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoButton extends StatelessWidget {
  const _PromoButton({
    required this.label,
    required this.onPressed,
    required this.height,
    required this.fontSize,
    required this.horizontalPadding,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;
  final double fontSize;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: height,
      child: Material(
        color: colors.brand,
        borderRadius: BorderRadius.circular(height * 0.5),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.buttonText.copyWith(
                    color: colors.onBrand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                  ),
                ),
                SizedBox(width: horizontalPadding * 0.7),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: fontSize + 4,
                  color: colors.onBrand,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}