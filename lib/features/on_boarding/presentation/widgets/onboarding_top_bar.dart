import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'onboarding_metrics.dart';

class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    super.key,
    required this.metrics,
    required this.onSkip,
  });

  final OnboardingMetrics metrics;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Semantics(
          button: true,
          label: 'Skip onboarding',
          child: InkWell(
            onTap: onSkip,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              // Larger tap area on tablet
              padding: EdgeInsets.symmetric(
                horizontal: metrics.skipFont * 0.9,
                vertical: metrics.skipFont * 0.55,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'skip',
                    style: TextStyle(
                      fontSize: metrics.skipFont,
                      fontWeight: FontWeight.w600,
                      color: colors.onboardingBody,
                    ),
                  ),
                  SizedBox(width: metrics.skipFont * 0.25),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: metrics.skipFont * 0.75,
                    color: colors.onboardingBody,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
