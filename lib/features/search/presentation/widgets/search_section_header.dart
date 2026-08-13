import 'package:flutter/material.dart';
import '../../../../core/matrics/search_metrics.dart';
import '../../../../core/theme/app_theme_colors.dart';

class SearchSectionHeader extends StatelessWidget {
  const SearchSectionHeader({
    super.key,
    required this.metrics,
    required this.title,
    this.actionText,
    this.showChevron = true,
    this.onActionTap,
  });

  final SearchMetrics metrics;
  final String title;
  final String? actionText;
  final bool showChevron;
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
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.sectionTitleSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: c.textPrimary,
              ),
            ),
          ),
          if (actionText != null && actionText!.isNotEmpty)
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
                    if (showChevron) ...[
                      SizedBox(width: m.pagePadding * 0.2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: m.viewAllSize * 1.5,
                        color: c.brand,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
