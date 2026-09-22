import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'auth_metrics.dart';


class AuthTermsCheckbox extends StatelessWidget {
  final AuthMetrics m;
  final bool value;
  final bool showError;
  final ValueChanged<bool> onChanged;

  const AuthTermsCheckbox({
    super.key,
    required this.m,
    required this.value,
    required this.showError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final checkboxSize = m.linkText + 8;
    final checkboxGap = m.fieldGap * 0.6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!value),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: checkboxSize,
                height: checkboxSize,
                child: Checkbox(
                  value: value,
                  onChanged: (checked) => onChanged(checked ?? false),
                  activeColor: colors.brand,
                  side: BorderSide(
                    color: showError ? colors.error : colors.border,
                    width: 1.4,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              SizedBox(width: checkboxGap),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: m.linkText,
                      color: colors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors.brand,
                          decorationColor: colors.brand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showError)
          Padding(
            padding: EdgeInsets.only(
              top: m.footerText * 0.3,
              left: checkboxSize + checkboxGap,
            ),
            child: Text(
              'You must accept the Terms and Conditions',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: m.footerText,
                color: colors.error,
              ),
            ),
          ),
      ],
    );
  }
}
