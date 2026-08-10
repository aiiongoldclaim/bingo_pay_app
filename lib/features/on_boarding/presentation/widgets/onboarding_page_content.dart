import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../data/model/on_boarding_feature.dart';
import 'onboarding_metrics.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.content,
    required this.m,
  });

  final OnBoardingContent content;
  final OnboardingMetrics m;

  @override
  Widget build(BuildContext context) {
    return m.isRow ? _landscape(context) : _portrait(context);
  }

  // ── Portrait: image upar, text neeche ──
  Widget _portrait(BuildContext context) {
    final p = OnboardingPalette.of(context);

    return LayoutBuilder(
      builder: (context, c) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  content.imageFor(p.isDark),
                  width: m.imageWidth,
                  height: m.imageHeight,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: m.gapImage),
                _Title(content: content, m: m, p: p, center: true),
                SizedBox(height: m.gapTitle),
                Text(
                  content.subTitle,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.subtitle,
                    height: 1.55,
                    color: p.body,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Landscape: text left, image right ──
  Widget _landscape(BuildContext context) {
    final p = OnboardingPalette.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Title(content: content, m: m, p: p, center: false),
                SizedBox(height: m.gapTitle),
                Text(
                  content.subTitle,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.subtitle,
                    height: 1.55,
                    color: p.body,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: m.gapImage),
        Expanded(
          flex: 5,
          child: Image.asset(
            content.imageFor(p.isDark),
            width: m.imageWidth,
            height: m.imageHeight,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.content,
    required this.m,
    required this.p,
    required this.center,
  });

  final OnBoardingContent content;
  final OnboardingMetrics m;
  final OnboardingPalette p;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: m.title,
      fontWeight: FontWeight.w700,
      height: 1.22,
    );

    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          content.title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(color: p.title),
        ),
        Text(
          content.titleHighlight,
          textAlign: center ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(
            color: p.isDark ? ThemeColors.gold : ThemeColors.blue,
          ),
        ),
      ],
    );
  }
}
