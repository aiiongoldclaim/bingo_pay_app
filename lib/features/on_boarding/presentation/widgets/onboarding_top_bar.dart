import 'package:flutter/material.dart';
import 'onboarding_metrics.dart';

class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({super.key, required this.m, required this.onSkip});

  final OnboardingMetrics m;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final p = OnboardingPalette.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: onSkip,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            // tablet pe bada tap area
            padding: EdgeInsets.symmetric(
              horizontal: m.skipFont * 0.9,
              vertical: m.skipFont * 0.55,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'skip',
                  style: TextStyle(
                    fontSize: m.skipFont,
                    fontWeight: FontWeight.w600,
                    color: p.skip,
                  ),
                ),
                SizedBox(width: m.skipFont * 0.25),
                Icon(
                  Icons.arrow_forward_ios,
                  size: m.skipFont * 0.75,
                  color: p.skip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
