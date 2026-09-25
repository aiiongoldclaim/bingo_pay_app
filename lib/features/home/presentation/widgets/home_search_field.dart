import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';
import '../models/vault_theme_colors.dart';
import 'home_metrics.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({
    super.key,
    required this.metrics,
    required this.hintText,
    required this.activeTheme,
    this.onTap,
  });

  final HomeMetrics metrics;
  final String hintText;
  final VaultThemeColors activeTheme;
  final VoidCallback? onTap;

  static const _animationDuration = Duration(milliseconds: 350);
  static const _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: _animationCurve,
        height: metrics.searchHeight,
        padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding * 0.85),
        decoration: BoxDecoration(
          color: ThemeColors.white,
          borderRadius: BorderRadius.circular(metrics.searchRadius),
          border: Border.all(color: activeTheme.searchBorder),
          boxShadow: [
            BoxShadow(
              color: activeTheme.primary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: activeTheme.searchIcon),
              duration: _animationDuration,
              curve: _animationCurve,
              builder: (context, animatedColor, _) => Icon(
                Icons.search_rounded,
                size: metrics.searchIconSize,
                color: animatedColor ?? activeTheme.searchIcon,
              ),
            ),
            SizedBox(width: metrics.pagePadding * 0.7),
            Expanded(
              child: Text(
                hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: metrics.searchFontSize,
                  color: ThemeColors.vaultSelectorSecondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
