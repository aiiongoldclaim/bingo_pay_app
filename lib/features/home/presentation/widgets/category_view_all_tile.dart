import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'home_metrics.dart';

class CategoryViewAllTile extends StatelessWidget {
  const CategoryViewAllTile({
    super.key,
    required this.metrics,
    this.label = 'View All',
    this.onTap,
  });

  final HomeMetrics metrics;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.categoryCircle),
      child: SizedBox(
        width: m.categoryItemWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: m.categoryCircle,
              height: m.categoryCircle,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
                border: Border.all(color: c.brand, width: 1.2),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: m.categoryIconSize * 0.85,
                color: c.brand,
              ),
            ),
            SizedBox(height: m.pagePadding * 0.45),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: m.categoryLabelSize,
                fontWeight: FontWeight.w600,
                height: 1.15,
                color: c.brand,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
