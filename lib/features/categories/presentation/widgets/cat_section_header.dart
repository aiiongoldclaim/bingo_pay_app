import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'categories_metrics.dart';

class CatSectionHeader extends StatelessWidget {
  const CatSectionHeader({
    super.key,
    required this.metrics,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  final CategoriesMetrics metrics;
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.sectionTitleSize,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: c.textPrimary,
              ),
            ),
          ),
          if (actionText != null && onActionTap != null)
            InkWell(
              onTap: onActionTap,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: m.pagePadding * 0.3),
                child: Row(
                  children: [
                    Text(
                      actionText!,
                      style: TextStyle(
                        fontSize: m.viewAllSize,
                        fontWeight: FontWeight.w600,
                        color: c.brand,
                      ),
                    ),
                    SizedBox(width: m.pagePadding * 0.3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: m.viewAllSize * 1.3,
                      color: c.brand,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
