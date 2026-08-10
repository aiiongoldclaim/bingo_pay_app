import 'package:flutter/material.dart';

import '../../../../core/theme/theme_colors.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDark
            ? ThemeColors.onboardingDarkBg
            : const LinearGradient(
                colors: [ThemeColors.surface, ThemeColors.background],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
    );
  }
}
