import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'home_metrics.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.metrics,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  final HomeMetrics metrics;
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: metrics.sectionTitleSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: c.textPrimary,
            ),
          ),
        ),
        if (actionText != null && actionText!.isNotEmpty)
          InkWell(
            onTap: onActionTap,
            child: Row(
              children: [
                Text(
                  actionText!.toUpperCase(),
                  style: TextStyle(
                    fontSize: metrics.viewAllSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: c.brand,
                  ),
                ),
                SizedBox(width: metrics.pagePadding * 0.2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: metrics.viewAllSize * 1.5,
                  color: c.brand,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
