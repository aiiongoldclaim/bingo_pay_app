import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import 'auth_metrics.dart';

class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({
    super.key,
    required this.metrics,
    required this.value,
  });

  final AuthMetrics metrics;
  final String value;

  /// Rules ek hi jagah — kahin aur bhi chahiye to yahi se aayenge.
  static Map<String, bool> checks(String value) => {
    'At least 8 characters': value.length >= 8,
    'One uppercase letter (A-Z)': RegExp(r'[A-Z]').hasMatch(value),
    'One lowercase letter (a-z)': RegExp(r'[a-z]').hasMatch(value),
    'One number (0-9)': RegExp(r'[0-9]').hasMatch(value),
    'One special character (!@#\$%...)': RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-+=~`\[\];/\\]',
    ).hasMatch(value),
  };

  static bool isStrong(String value) => checks(value).values.every((ok) => ok);

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dark bg pe plain green thoda dab jata hai — halka bright kar dete hain.
    final metColor = isDark
        ? Color.alphaBlend(
            ThemeColors.white.withValues(alpha: 0.25),
            ThemeColors.green,
          )
        : ThemeColors.green;
    final unmetColor = isDark ? ThemeColors.textGrey : ThemeColors.inkDim;

    final rules = checks(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rules.entries.map((e) {
        final ok = e.value;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: m.fieldGap * 0.18),
          child: Row(
            children: [
              Icon(
                ok ? Icons.check_circle : Icons.circle_outlined,
                size: m.footerText + 4,
                color: ok ? metColor : unmetColor,
              ),
              SizedBox(width: m.fieldGap * 0.45),
              Flexible(
                child: Text(
                  e.key,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: m.footerText,
                    fontWeight: ok ? FontWeight.w600 : FontWeight.w400,
                    color: ok ? metColor : unmetColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
