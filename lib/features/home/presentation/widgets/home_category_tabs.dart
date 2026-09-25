import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'home_metrics.dart';

class HomeCategoryTabs extends StatelessWidget {
  const HomeCategoryTabs({
    super.key,
    required this.metrics,
    required this.labels,
    required this.selectedIndex,
    this.onSelected,
    this.onViewAll,
    this.viewAllLabel = 'View All',
    this.activeColor,
    this.dividerColor,
  });

  final HomeMetrics metrics;
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final VoidCallback? onViewAll;
  final String viewAllLabel;
  final Color? activeColor;
  final Color? dividerColor;

  static const _animationDuration = Duration(milliseconds: 320);
  static const _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    final colors = context.c;
    final resolvedActiveColor = activeColor ?? colors.brand;
    final resolvedDividerColor = dividerColor ?? colors.border;

    final itemCount = labels.length + (onViewAll != null ? 1 : 0);

    return SizedBox(
      height: metrics.tabBarHeight,
      child: Stack(
        children: [
          Positioned(
            left: metrics.pagePadding,
            right: metrics.pagePadding,
            bottom: 0,
            child: AnimatedContainer(
              duration: _animationDuration,
              curve: _animationCurve,
              height: 1,
              color: resolvedDividerColor,
            ),
          ),
          ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
            itemCount: itemCount,
            separatorBuilder: (_, __) => SizedBox(width: metrics.tabGap),
            itemBuilder: (context, i) {
              final selected = i == selectedIndex;
              final targetColor =
                  selected ? resolvedActiveColor : colors.textSecondary;

              return InkWell(
                onTap: () => onSelected?.call(i),
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: targetColor),
                  duration: _animationDuration,
                  curve: _animationCurve,
                  builder: (context, animatedColor, _) {
                    final color = animatedColor ?? targetColor;
                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              labels[i].toUpperCase(),
                              style: TextStyle(
                                fontSize: metrics.tabFontSize,
                                letterSpacing: 0.5,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 2.5,
                          color: selected ? color : Colors.transparent,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
