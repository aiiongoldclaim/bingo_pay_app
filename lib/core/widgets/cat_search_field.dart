import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';
import '../../features/categories/presentation/widgets/categories_metrics.dart';

class CatSearchField extends StatelessWidget {
  const CatSearchField({
    super.key,
    required this.metrics,
    required this.hintText,
    this.onTap,

  });

  final CategoriesMetrics metrics;
  final String hintText;
  final VoidCallback? onTap;


  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: m.searchHeight,
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 0.85),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.searchRadius),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: m.searchIconSize,
              color: c.textMuted,
            ),
            SizedBox(width: m.pagePadding * 0.7),
            Expanded(
              child: Text(
                hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: m.searchFontSize,
                  color: c.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
