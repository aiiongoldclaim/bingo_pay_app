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
  });

  final HomeMetrics metrics;
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    final c = context.c;

    return SizedBox(
      height: metrics.tabBarHeight,
      child: Stack(
        children: [
          Positioned(
            left: metrics.pagePadding,
            right: metrics.pagePadding,
            bottom: 0,
            child: Container(height: 1, color: c.border),
          ),
          ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
            itemCount: labels.length,
            separatorBuilder: (_, __) => SizedBox(width: metrics.tabGap),
            itemBuilder: (context, i) {
              final selected = i == selectedIndex;
              return InkWell(
                onTap: () => onSelected?.call(i),
                child: Column(
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
                            color: selected ? c.brand : c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 2.5,
                      color: selected ? c.brand : Colors.transparent,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
