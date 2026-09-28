import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';
import 'bottom_nav_metrics.dart';

@immutable
class BottomNavItemData {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const BottomNavItemData({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.items = defaultItems,
    this.badges = const {},
    this.activeColorOverride,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<BottomNavItemData> items;

  final Map<int, int> badges;

  final Color? activeColorOverride;

  static const List<BottomNavItemData> defaultItems = [
    BottomNavItemData(
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: 'Home',
    ),
    BottomNavItemData(
      activeIcon: Icons.grid_view_rounded,
      inactiveIcon: Icons.grid_view_outlined,
      label: 'Categories',
    ),
    BottomNavItemData(
      activeIcon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
    BottomNavItemData(
      activeIcon: Icons.menu_rounded,
      inactiveIcon: Icons.menu_rounded,
      label: 'Browse',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final m = BottomNavMetrics.of(context);
    final colors = context.c;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.navBackground,
        border: Border(
          top: BorderSide(color: colors.border, width: m.topBorderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: m.barHeight,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: m.horizontalPadding),
                child: Row(
                  children: List.generate(items.length, (i) {
                    return _NavItem(
                      metrics: m,
                      data: items[i],
                      selected: i == currentIndex,
                      badgeCount: badges[i] ?? 0,
                      activeColorOverride: activeColorOverride,
                      onTap: () => onTap?.call(i),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav item ────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.metrics,
    required this.data,
    required this.selected,
    required this.badgeCount,
    required this.onTap,
    this.activeColorOverride,
  });

  final BottomNavMetrics metrics;
  final BottomNavItemData data;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;
  final Color? activeColorOverride;

  static const _animationDuration = Duration(milliseconds: 320);
  static const _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final targetColor = selected
        ? (activeColorOverride ?? colors.navSelected)
        : colors.navUnselected;

    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: m.iconSize * 1.6,
        highlightShape: BoxShape.rectangle,
        containedInkWell: true,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: targetColor),
          duration: _animationDuration,
          curve: _animationCurve,
          builder: (context, animatedColor, _) {
            final color = animatedColor ?? targetColor;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      selected ? data.activeIcon : data.inactiveIcon,
                      size: m.iconSize,
                      color: color,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        top: -m.badgeSize * 0.35,
                        right: -m.badgeSize * 0.35,
                        child: _Badge(metrics: m, count: badgeCount),
                      ),
                  ],
                ),
                SizedBox(height: m.iconLabelGap),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.labelSize,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.1,
                    letterSpacing: 0.1,
                    color: color,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Badge ───────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.metrics, required this.count});

  final BottomNavMetrics metrics;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Container(
      width: metrics.badgeSize,
      height: metrics.badgeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.navSelected,
        shape: BoxShape.circle,
        border: Border.all(color: colors.navBackground, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          fontSize: metrics.badgeFontSize,
          fontWeight: FontWeight.w700,
          height: 1,
          color: Colors.white,
        ),
      ),
    );
  }
}
