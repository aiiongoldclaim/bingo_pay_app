import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'onboarding_metrics.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currentPage,
    required this.metrics,
  });

  final int count;
  final int currentPage;
  final OnboardingMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: 'Page ${currentPage + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? metrics.dotSize * 2.4 : metrics.dotSize,
            height: metrics.dotSize,
            decoration: BoxDecoration(
              color: isActive
                  ? colors.onboardingAccent
                  : colors.onboardingDotIdle,
              borderRadius: BorderRadius.circular(metrics.dotSize),
            ),
          );
        }),
      ),
    );
  }
}