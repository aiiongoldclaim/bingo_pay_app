import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'auth_metrics.dart';

class AuthSecureNote extends StatelessWidget {
  const AuthSecureNote({
    super.key,
    required this.metrics,
    this.text = 'Your data is 100% secure and private',
    this.icon = Icons.lock_outline_rounded,
    this.alignment = MainAxisAlignment.center,
  });

  final AuthMetrics metrics;
  final String text;
  final IconData icon;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        Icon(
          icon,
          size: metrics.footerText + 2,
          color: colors.textMuted,
        ),

        SizedBox(width: metrics.fieldGap * 0.35),

        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: metrics.footerText,
              color: colors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}