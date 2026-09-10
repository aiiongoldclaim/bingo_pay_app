import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'profile_metrics.dart';

class ProfileErrorView extends StatelessWidget {
  const ProfileErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = ProfileMetrics.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: colors.brand,
                size: m.walletIconSize * 1.6,
              ),

              SizedBox(height: m.gapMd),

              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.menuTitleSize,
                ),
              ),

              SizedBox(height: m.gapLg),

              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.brand,
                  side: BorderSide(color: colors.brand),
                  padding: EdgeInsets.symmetric(
                    horizontal: m.walletHPad * 1.8,
                    vertical: m.menuItemVPad,
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
