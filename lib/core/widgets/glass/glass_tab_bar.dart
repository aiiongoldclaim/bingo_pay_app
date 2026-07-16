import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_glass.dart';
import 'glass_border.dart';

class GlassTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const GlassTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Floating frosted pill tab bar (iOS Liquid Glass style).
///
/// Uses a real backdrop blur because screen content scrolls underneath it —
/// pair with `extendBody: true` on the hosting [Scaffold].
class GlassTabBar extends StatelessWidget {
  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF9DB4FF) : AppColors.primary;
    final inactiveColor = context.colors.textSecondary;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: glass.shadow,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: glass.fill,
                borderRadius: BorderRadius.circular(30),
                border: GlassBorder(glass),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _TabButton(
                        item: items[i],
                        selected: i == currentIndex,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final GlassTabItem item;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? item.activeIcon : item.icon, size: 24, color: color),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
