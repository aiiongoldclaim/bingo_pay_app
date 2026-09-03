import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../data/model/on_boarding_feature.dart';
import 'onboarding_metrics.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.content,
    required this.metrics,
  });

  final OnBoardingContent content;
  final OnboardingMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return metrics.isRow ? _landscape(context) : _portrait(context);
  }

  Widget _portrait(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  content.imageFor(colors.isDark),
                  width: metrics.imageWidth,
                  height: metrics.imageHeight,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: metrics.gapImage),
                _Title(content: content, metrics: metrics, center: true),
                SizedBox(height: metrics.gapTitle),
                Text(
                  content.subTitle,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: metrics.subtitle,
                    height: 1.55,
                    color: colors.onboardingBody,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Landscape: image left, text right ──

  Widget _landscape(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Image.asset(
            content.imageFor(colors.isDark),
            width: metrics.imageWidth,
            height: metrics.imageHeight,
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(width: metrics.gapImage * 5),

        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Title(content: content, metrics: metrics, center: false),
                  SizedBox(height: metrics.gapTitle),
                  Text(
                    content.subTitle,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: metrics.subtitle,
                      height: 1.55,
                      color: colors.onboardingBody,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.content,
    required this.metrics,
    required this.center,
  });

  final OnBoardingContent content;
  final OnboardingMetrics metrics;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final style = TextStyle(
      fontSize: metrics.title,
      fontWeight: FontWeight.w700,
      height: 1.22,
    );

    return Column(
      crossAxisAlignment:
      center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          content.title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(color: colors.onboardingTitle),
        ),
        Text(
          content.titleHighlight,
          textAlign: center ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(color: colors.onboardingAccent),
        ),
      ],
    );
  }
}