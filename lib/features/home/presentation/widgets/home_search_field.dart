import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import 'home_metrics.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({
    super.key,
    required this.metrics,
    required this.hintText,
    this.onTap,
  });

  final HomeMetrics metrics;
  final String hintText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: metrics.searchHeight,
        padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding * 0.85),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(metrics.searchRadius),
          border: Border.all(color: ThemeColors.vaultSearchBorder),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.vaultSelectorPrimary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: metrics.searchIconSize,
              color: ThemeColors.vaultSelectorPrimary,
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
