import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: colors.onboardingBackground),
    );
  }
}