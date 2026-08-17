import 'package:flutter/material.dart';
import 'onboarding_metrics.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currenPage,
    required this.m,
  });

  final int count;
  final int currenPage;
  final OnboardingMetrics m;

  @override
  Widget build(BuildContext context) {
    final p = OnboardingPalette.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = currenPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? m.dotSize * 2.4 : m.dotSize,
          height: m.dotSize,
          decoration: BoxDecoration(
            color: active ? p.dotActive : p.dotIdle,
            borderRadius: BorderRadius.circular(m.dotSize),
          ),
        );
      }),
    );
  }
}
