import 'package:bingo_pay/features/splash/presentaion/widgets/splash_metrics.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/theme_colors.dart';
import '../screens/splash_screen.dart';

class SplashServiceIcons extends StatelessWidget {
  const SplashServiceIcons({
    super.key,
    required this.metrics,
    required this.isDark,
  });

  final SplashMetrics metrics;
  final bool isDark;

  static const _icons = <IconData>[
    Icons.shopping_bag_outlined,
    Icons.storefront_outlined,
    Icons.content_cut_rounded,
    Icons.room_service_outlined,
    Icons.add_box_outlined,
  ];

  static const _accentIndexes = {2, 3};

  @override
  Widget build(BuildContext context) {
    final base = isDark ? ThemeColors.white : ThemeColors.textDark;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_icons.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Container(
              width: 1,
              height: metrics.dividerHeight,
              margin: EdgeInsets.symmetric(horizontal: metrics.iconGap / 2),
              color: (isDark ? ThemeColors.white : ThemeColors.ink).withValues(
                alpha: isDark ? 0.18 : 0.12,
              ),
            );
          }

          final index = i ~/ 2;
          return SizedBox(
            width: metrics.iconBoxSize,
            height: metrics.iconBoxSize,
            child: Icon(
              _icons[index],
              size: metrics.iconSize,
              color: _accentIndexes.contains(index)
                  ? ThemeColors.gold
                  : base.withValues(alpha: 0.9),
            ),
          );
        }),
      ),
    );
  }
}
