import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import 'auth_metrics.dart';

class AuthTopBar extends StatelessWidget {
  const AuthTopBar({
    super.key,
    required this.m,
    this.brandFirst = 'The',
    this.brandSecond = 'Vaults',
    this.tagline = 'YOUR EVERYDAY STORE',
    this.onBack,
    this.actionLabel,
    this.onAction,
  });

  final AuthMetrics m;
  final String brandFirst;
  final String brandSecond;
  final String tagline;
  final VoidCallback? onBack;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (onBack != null)
          InkResponse(
            onTap: onBack,
            radius: 24,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: m.logoBox * 0.48,
                color: colors.textPrimary,
              ),
            ),
          )
        else
          Container(
            width: m.logoBox,
            height: m.logoBox,
            decoration: BoxDecoration(
              gradient: ThemeColors.bottomSection,
              borderRadius: BorderRadius.circular(m.logoBox * 0.28),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: ThemeColors.white,
              size: m.logoBox * 0.55,
            ),
          ),
        SizedBox(width: m.logoBox * 0.28),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: brandFirst,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: m.brandTitle,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: colors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: brandSecond,
                    style: TextStyle(
                        color: colors.brand
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: m.brandTagline * 0.25),
            Text(
              tagline,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: m.brandTagline,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (actionLabel != null && m.isTablet)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: m.linkText,
                color: colors.brand,
              ),
            ),
          ),
      ],
    );
  }
}
