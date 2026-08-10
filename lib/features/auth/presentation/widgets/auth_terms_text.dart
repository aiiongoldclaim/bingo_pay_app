import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import 'auth_metrics.dart';

class AuthTermsText extends StatelessWidget {
  const AuthTermsText({
    required this.m,
    this.prefix = 'By continuing, you agree to our',
    this.separator = 'and',
    this.termsLabel = 'Terms of Service',
    this.privacyLabel = 'Privacy Policy',
    this.onTapTerms,
    this.onTapPrivacy,
    super.key,
  });

  final AuthMetrics m;
  final String prefix;
  final String separator;
  final String termsLabel;
  final String privacyLabel;
  final VoidCallback? onTapTerms;
  final VoidCallback? onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? ThemeColors.inkDim : ThemeColors.inkMid;

    final plainStyle = AppTextStyles.bodySmall.copyWith(
      fontSize: m.footerText,
      color: muted,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(prefix, textAlign: TextAlign.center, style: plainStyle),
        SizedBox(height: m.footerText * 0.3),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AuthLegalLink(
              text: termsLabel,
              fontSize: m.footerText,
              onTap: onTapTerms,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: m.footerText * 0.4),
              child: Text(separator, style: plainStyle),
            ),
            AuthLegalLink(
              text: privacyLabel,
              fontSize: m.footerText,
              onTap: onTapPrivacy,
            ),
          ],
        ),
      ],
    );
  }
}

/// Underlined blue link — alag se bhi use kar sakti ho.
class AuthLegalLink extends StatelessWidget {
  const AuthLegalLink({
    required this.text,
    required this.fontSize,
    this.onTap,
    super.key,
  });

  final String text;
  final double fontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        style: AppTextStyles.labelLarge.copyWith(
          fontSize: fontSize,
          color: ThemeColors.purple,
          decoration: TextDecoration.underline,
          decorationColor: ThemeColors.purple,
        ),
      ),
    );
  }
}
