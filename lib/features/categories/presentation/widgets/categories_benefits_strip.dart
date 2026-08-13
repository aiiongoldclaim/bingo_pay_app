import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'categories_metrics.dart';

@immutable
class CatBenefitData {
  final IconData icon;
  final String title;
  final String subtitle;

  const CatBenefitData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class CategoriesBenefitsStrip extends StatelessWidget {
  const CategoriesBenefitsStrip({
    super.key,
    required this.metrics,
    required this.benefits,
  });

  final CategoriesMetrics metrics;
  final List<CatBenefitData> benefits;

  @override
  Widget build(BuildContext context) {
    if (benefits.isEmpty) return const SizedBox.shrink();
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: m.pagePadding * 0.5,
          vertical: m.pagePadding * 0.8,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.categoryTileRadius),
          border: Border.all(color: c.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < benefits.length; i++) ...[
              Expanded(
                child: _Item(metrics: m, data: benefits[i]),
              ),
              if (i != benefits.length - 1)
                Container(
                  width: 1,
                  height: m.benefitIconSize * 1.8,
                  color: c.border,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.metrics, required this.data});

  final CategoriesMetrics metrics;
  final CatBenefitData data;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: m.benefitIconSize, color: c.brand),
          SizedBox(height: m.pagePadding * 0.4),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: m.benefitTitleSize,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: m.pagePadding * 0.15),
          Text(
            data.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: m.benefitBodySize,
              height: 1.3,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
