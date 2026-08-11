import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import 'auth_metrics.dart';

class AuthSecureNote extends StatelessWidget {
  const AuthSecureNote({
    super.key,
    required this.m,
    this.isDark,
    this.text = 'Your data is 100% secure and private',
    this.icon = Icons.lock_outline_rounded,
    this.alignment = MainAxisAlignment.center,
  });

  final AuthMetrics m;

  final bool? isDark;
  final String text;
  final IconData icon;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? ThemeColors.textGrey : ThemeColors.inkDim;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        Icon(icon, size: m.footerText + 2, color: muted),
        SizedBox(width: m.fieldGap * 0.35),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: m.footerText,
              color: muted,
            ),
          ),
        ),
      ],
    );
  }
}
