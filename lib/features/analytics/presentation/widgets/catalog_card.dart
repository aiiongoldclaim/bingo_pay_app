import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/vendor_analytics_model.dart';
import 'analytics_card.dart';

/// Catalog status share as a stacked segment bar with a labeled legend —
/// published / pending / draft, unknown statuses folded into "Other".
class CatalogCard extends StatelessWidget {
  final AnalyticsCatalog catalog;

  const CatalogCard({super.key, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = NumberFormat.decimalPattern();
    const knownStatuses = ['PUBLISHED', 'PENDING_ADMIN_APPROVAL', 'DRAFT'];
    final other = catalog.byStatus.entries
        .where((e) => !knownStatuses.contains(e.key))
        .fold(0, (sum, e) => sum + e.value);
    final segments = <({String label, int value, Color color})>[
      if (catalog.byStatus['PUBLISHED'] case final published?)
        (label: 'Published', value: published, color: colors.successFg),
      if (catalog.byStatus['PENDING_ADMIN_APPROVAL'] case final pending?)
        (label: 'Pending approval', value: pending, color: colors.warningFg),
      if (catalog.byStatus['DRAFT'] case final draft?)
        (label: 'Draft', value: draft, color: colors.infoFg),
      if (other > 0) (label: 'Other', value: other, color: colors.textMuted),
    ];
    final total = segments.fold(0, (sum, s) => sum + s.value);

    return AnalyticsCard(
      title: 'Catalog',
      subtitle:
          '${count.format(catalog.totalProducts)} products'
          '${catalog.featuredProducts > 0 ? ' · ${catalog.featuredProducts} featured' : ''}',
      child: total == 0
          ? Text(
              'No products yet',
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      children: [
                        for (final (i, segment) in segments.indexed)
                          if (segment.value > 0) ...[
                            if (i > 0 &&
                                segments.take(i).any((s) => s.value > 0))
                              const SizedBox(width: 2),
                            Expanded(
                              flex: segment.value,
                              child: ColoredBox(color: segment.color),
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.sm + 4),
                Wrap(
                  spacing: AppDimensions.md,
                  runSpacing: 4,
                  children: [
                    for (final segment in segments)
                      if (segment.value > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: segment.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${segment.label} ${count.format(segment.value)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ],
            ),
    );
  }
}
