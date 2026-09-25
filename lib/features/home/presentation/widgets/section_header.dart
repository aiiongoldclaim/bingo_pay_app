import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'home_metrics.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.metrics,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.titleColor,
    this.actionColor,
    this.highlightPrefix,
    this.highlightColor,
  });

  final HomeMetrics metrics;
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  final Color? titleColor;
  final Color? actionColor;

  final String? highlightPrefix;
  final Color? highlightColor;

  static const _animationDuration = Duration(milliseconds: 320);
  static const _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final resolvedTitleColor = titleColor ?? colors.textPrimary;
    final resolvedActionColor = actionColor ?? colors.brand;

    final displayTitle = title.toUpperCase();
    final prefix = highlightPrefix?.toUpperCase();
    final hasHighlight =
        prefix != null &&
        prefix.isNotEmpty &&
        displayTitle.startsWith(prefix);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: hasHighlight
              ? _HighlightedTitle(
                  fullText: displayTitle,
                  highlightLength: prefix.length,
                  fontSize: metrics.sectionTitleSize,
                  baseColor: resolvedTitleColor,
                  highlightColor: highlightColor ?? resolvedTitleColor,
                )
              : TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: resolvedTitleColor),
                  duration: _animationDuration,
                  curve: _animationCurve,
                  builder: (context, animatedColor, _) => Text(
                    displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: metrics.sectionTitleSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: animatedColor ?? resolvedTitleColor,
                    ),
                  ),
                ),
        ),
        if (actionText != null && actionText!.isNotEmpty)
          InkWell(
            onTap: onActionTap,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: resolvedActionColor),
              duration: _animationDuration,
              curve: _animationCurve,
              builder: (context, animatedColor, _) {
                final color = animatedColor ?? resolvedActionColor;
                return Row(
                  children: [
                    Text(
                      actionText!.toUpperCase(),
                      style: TextStyle(
                        fontSize: metrics.viewAllSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: color,
                      ),
                    ),
                    SizedBox(width: metrics.pagePadding * 0.2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: metrics.viewAllSize * 1.5,
                      color: color,
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}

class _HighlightedTitle extends StatelessWidget {
  const _HighlightedTitle({
    required this.fullText,
    required this.highlightLength,
    required this.fontSize,
    required this.baseColor,
    required this.highlightColor,
  });

  final String fullText;
  final int highlightLength;
  final double fontSize;
  final Color baseColor;
  final Color highlightColor;

  static const _animationDuration = Duration(milliseconds: 320);
  static const _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: highlightColor),
      duration: _animationDuration,
      curve: _animationCurve,
      builder: (context, animatedHighlight, _) {
        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: baseColor),
          duration: _animationDuration,
          curve: _animationCurve,
          builder: (context, animatedBase, _) {
            return Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: animatedBase ?? baseColor,
                ),
                children: [
                  TextSpan(
                    text: fullText.substring(0, highlightLength),
                    style: TextStyle(
                      color: animatedHighlight ?? highlightColor,
                    ),
                  ),
                  TextSpan(text: fullText.substring(highlightLength)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        );
      },
    );
  }
}
