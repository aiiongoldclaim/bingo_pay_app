import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';
import '../utils/responsive_utils.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    required this.prefix,
    required this.action,
    required this.onTap,
    this.fontSize,
    super.key,
  });

  final String prefix;
  final String action;
  final VoidCallback onTap;

  /// Optional override — screen ke Metrics se pass kar sakti ho
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final m = _FooterMetrics.get();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = fontSize ?? m.font;

    // colors theme se — koi raw hex nahi
    final prefixColor = isDark ? ThemeColors.inkDim : ThemeColors.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefix,
          style:
              theme.textTheme.bodyMedium?.copyWith(
                fontSize: size,
                fontWeight: FontWeight.w500,
                color: prefixColor,
              ) ??
              TextStyle(
                fontFamily: 'Roboto',
                fontSize: size,
                fontWeight: FontWeight.w500,
                color: prefixColor,
              ),
        ),
        SizedBox(width: m.gap),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(m.tapRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: m.tapPadH,
              vertical: m.tapPadV,
            ),
            child: Text(
              action,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: size,
                fontWeight: FontWeight.w700,
                color: ThemeColors.purple,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Phone / tablet-portrait / tablet-landscape sizing.
/// Saari values REAL dp hain — Sizer `.sp` nahi.
class _FooterMetrics {
  const _FooterMetrics({
    required this.font,
    required this.gap,
    required this.tapPadH,
    required this.tapPadV,
    required this.tapRadius,
  });

  final double font;
  final double gap;
  final double tapPadH;
  final double tapPadV;
  final double tapRadius;

  factory _FooterMetrics.get() {
    if (ResponsiveUtils.isTabletLandscape) {
      return const _FooterMetrics(
        font: 15,
        gap: 6,
        tapPadH: 6,
        tapPadV: 4,
        tapRadius: 8,
      );
    }

    if (ResponsiveUtils.isTabletPortrait) {
      return const _FooterMetrics(
        font: 16,
        gap: 7,
        tapPadH: 7,
        tapPadV: 5,
        tapRadius: 8,
      );
    }

    // phone
    return const _FooterMetrics(
      font: 14,
      gap: 5,
      tapPadH: 6,
      tapPadV: 4,
      tapRadius: 8,
    );
  }
}
