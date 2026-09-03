import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'onboarding_metrics.dart';
import 'page_indicator.dart';

class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.metrics,
    required this.currentPage,
    required this.total,
    required this.onBack,
    required this.onNext,
  });

  final OnboardingMetrics metrics;
  final int currentPage;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLast = currentPage == total - 1;
    final isFirst = currentPage == 0;

    return Row(
      children: [
        // Back — hidden on the first page, but its space stays reserved
        Opacity(
          opacity: isFirst ? 0 : 1,
          child: IgnorePointer(
            ignoring: isFirst,
            child: Semantics(
              button: true,
              label: 'Back',
              enabled: !isFirst,
              hidden: isFirst,
              child: _PillButton(
                label: 'back',
                icon: Icons.arrow_back,
                iconLeading: true,
                fill: null,
                gradient: null,
                border: colors.onboardingBorder,
                textColor: colors.onboardingTitle,
                metrics: metrics,
                onTap: onBack,
              ),
            ),
          ),
        ),

        Expanded(
          child: PageIndicator(
            count: total,
            currentPage: currentPage,
            metrics: metrics,
          ),
        ),

        Semantics(
          button: true,
          label: isLast ? 'Get Started' : 'Next',
          child: _PillButton(
            label: isLast ? 'Get Started' : 'Next',
            icon: isLast ? null : Icons.arrow_forward,
            iconLeading: false,
            fill: null,
            gradient: colors.onboardingNextGradient,
            border: null,
            textColor: colors.onboardingNextText,
            metrics: metrics,
            onTap: onNext,
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.iconLeading,
    required this.fill,
    required this.gradient,
    required this.border,
    required this.textColor,
    required this.metrics,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool iconLeading;
  final Color? fill;
  final Gradient? gradient;
  final Color? border;
  final Color textColor;
  final OnboardingMetrics metrics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: metrics.buttonFont,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );

    final children = icon == null
        ? [text]
        : iconLeading
        ? [
      Icon(icon, size: metrics.buttonFont + 3, color: textColor),
      const SizedBox(width: 8),
      text,
    ]
        : [
      text,
      const SizedBox(width: 8),
      Icon(icon, size: metrics.buttonFont + 3, color: textColor),
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(metrics.buttonHeight / 2),
      child: Container(
        height: metrics.buttonHeight,
        width: metrics.buttonWidth,
        decoration: BoxDecoration(
          color: fill,
          gradient: gradient,
          border: border != null ? Border.all(color: border!) : null,
          borderRadius: BorderRadius.circular(metrics.buttonHeight / 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}