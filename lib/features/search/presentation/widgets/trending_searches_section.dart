import 'package:flutter/material.dart';

import '../../../../core/matrics/search_metrics.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'search_catalog.dart';
import 'search_section_header.dart';

class TrendingSearchesSection extends StatelessWidget {
  const TrendingSearchesSection({
    super.key,
    required this.metrics,
    required this.items,
    this.onItemTap,
    this.onViewAll,
  });

  final SearchMetrics metrics;
  final List<TrendingSearchData> items;
  final ValueChanged<TrendingSearchData>? onItemTap;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchSectionHeader(
          metrics: m,
          title: 'Trending Searches',
          actionText: 'View All',
          onActionTap: onViewAll,
        ),
        SizedBox(height: m.pagePadding * 0.7),
        SizedBox(
          height: m.trendingRowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: m.pagePadding * 0.6),
            itemBuilder: (_, i) => _TrendingTile(
              metrics: m,
              data: items[i],
              onTap: () => onItemTap?.call(items[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendingTile extends StatelessWidget {
  const _TrendingTile({required this.metrics, required this.data, this.onTap});

  final SearchMetrics metrics;
  final TrendingSearchData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.trendingRadius),
      child: SizedBox(
        width: m.trendingTileWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(m.trendingRadius),
              child: Container(
                width: m.trendingTileWidth,
                height: m.trendingImageHeight,
                color: c.surfaceAlt,
                child: Image.asset(
                  data.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_outlined,
                    size: m.inputIconSize,
                    color: c.textMuted,
                  ),
                ),
              ),
            ),
            SizedBox(height: m.pagePadding * 0.55),
            Flexible(
              child: Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: m.trendingLabelSize,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: c.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
