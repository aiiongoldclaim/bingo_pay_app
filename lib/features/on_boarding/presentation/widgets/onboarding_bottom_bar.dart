import 'package:bingo_pay/features/on_boarding/presentation/widgets/page_indicator.dart';
import 'package:flutter/material.dart';
import 'onboarding_metrics.dart';

class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.m,
    required this.currentPage,
    required this.total,
    required this.onBack,
    required this.onNext,
  });

  final OnboardingMetrics m;
  final int currentPage;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final p = OnboardingPalette.of(context);
    final isLast = currentPage == total - 1;

    return Row(
      children: [
        // Back — first page pe invisible but jagah reserved
        Opacity(
          opacity: currentPage == 0 ? 0 : 1,
          child: IgnorePointer(
            ignoring: currentPage == 0,
            child: _PillButton(
              label: 'back',
              icon: Icons.arrow_back,
              iconLeading: true,
              fill: null,
              gradient: null,
              border: p.backBorder,
              textColor: p.backText,
              m: m,
              onTap: onBack,
            ),
          ),
        ),
        Expanded(
          child: PageIndicator(count: total, currenPage: currentPage, m: m),
        ),
        _PillButton(
          label: isLast ? 'Get Started' : 'Next',
          icon: isLast ? null : Icons.arrow_forward,
          iconLeading: false,
          fill: p.nextFill,
          gradient: p.nextGradient,
          border: null,
          textColor: p.nextText,
          m: m,
          onTap: onNext,
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
    required this.m,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool iconLeading;
  final Color? fill;
  final Gradient? gradient;
  final Color? border;
  final Color textColor;
  final OnboardingMetrics m;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: TextStyle(
        fontSize: m.buttonFont,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
    final children = icon == null
        ? [text]
        : iconLeading
        ? [
            Icon(icon, size: m.buttonFont + 3, color: textColor),
            const SizedBox(width: 8),
            text,
          ]
        : [
            text,
            const SizedBox(width: 8),
            Icon(icon, size: m.buttonFont + 3, color: textColor),
          ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.buttonHeight / 2),
      child: Container(
        height: m.buttonHeight,
        width: m.buttonWidth,
        decoration: BoxDecoration(
          color: fill,
          gradient: gradient,
          border: border != null ? Border.all(color: border!) : null,
          borderRadius: BorderRadius.circular(m.buttonHeight / 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
