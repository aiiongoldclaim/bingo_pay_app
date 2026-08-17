import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../services/domain/entities/service_entity.dart';
import 'home_metrics.dart';

class BookServicesSection extends StatelessWidget {
  const BookServicesSection({
    super.key,
    required this.metrics,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.services,
    this.maxTiles = 4,
    this.viewAllLabel = 'View All',
    this.onBookNow,
    this.onServiceTap,
    this.onViewAll,
  });

  final HomeMetrics metrics;
  final String title;
  final String subtitle;
  final String buttonText;
  final List<ServiceEntity> services;
  final int maxTiles;
  final String viewAllLabel;
  final VoidCallback? onBookNow;
  final ValueChanged<ServiceEntity>? onServiceTap;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();
    final c = context.c;
    final m = metrics;

    final visible = services.take(maxTiles).toList();
    final tileCount = visible.length + 1; // +1 = View All tile

    return Container(
      padding: EdgeInsets.all(m.pagePadding),
      decoration: BoxDecoration(
        color: c.servicesBg,
        borderRadius: BorderRadius.circular(m.heroRadius * 0.75),
        border: c.isDark ? Border.all(color: c.border) : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = m.pagePadding * 0.4;

          // Left text column: phone pe ~40%, tablet pe ~30%
          final leftWidth = constraints.maxWidth * (m.isTablet ? 0.30 : 0.38);
          final rightWidth =
              constraints.maxWidth - leftWidth - m.pagePadding * 0.5;

          // Tile width available space se derive — HARDCODED NAHI
          final rawTileWidth = (rightWidth - gap * (tileCount - 1)) / tileCount;
          final scrollable = rawTileWidth < m.serviceTileMinWidth;
          final tileWidth = scrollable ? m.serviceTileMinWidth : rawTileWidth;

          final tiles = <Widget>[
            ...visible.map(
              (s) => _ServiceTile(
                metrics: m,
                width: tileWidth,
                label: s.title,
                imageUrl: s.imageUrl,
                onTap: () => onServiceTap?.call(s),
              ),
            ),
            _ServiceTile(
              metrics: m,
              width: tileWidth,
              label: viewAllLabel,
              imageUrl: '',
              fallbackIcon: Icons.grid_view_rounded,
              onTap: onViewAll,
            ),
          ];

          final tileHeight =
              m.serviceIconSize +
              m.serviceLabelSize * 1.4 +
              m.pagePadding * 1.3;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Left: heading + CTA ─────────────────────
              SizedBox(
                width: leftWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.sectionTitleSize * 0.8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        height: 1.2,
                        color: c.brand,
                      ),
                    ),
                    SizedBox(height: m.pagePadding * 0.3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.serviceLabelSize * 1.1,
                        height: 1.3,
                        color: c.textSecondary,
                      ),
                    ),
                    SizedBox(height: m.pagePadding * 0.6),
                    SizedBox(
                      height: m.searchHeight * 0.66,
                      child: ElevatedButton(
                        onPressed: onBookNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.brand,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.symmetric(
                            horizontal: m.pagePadding * 0.7,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            buttonText.toUpperCase(),
                            style: TextStyle(
                              fontSize: m.serviceLabelSize * 1.1,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: m.pagePadding * 0.5),

              // ── Right: service tiles ────────────────────
              SizedBox(
                width: rightWidth,
                height: tileHeight,
                child: scrollable
                    ? ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount: tiles.length,
                        separatorBuilder: (_, __) => SizedBox(width: gap),
                        itemBuilder: (_, i) => tiles[i],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: tiles,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.metrics,
    required this.width,
    required this.label,
    required this.imageUrl,
    this.fallbackIcon = Icons.design_services_outlined,
    this.onTap,
  });

  final HomeMetrics metrics;
  final double width;
  final String label;
  final String imageUrl;
  final IconData fallbackIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(
          vertical: m.pagePadding * 0.45,
          horizontal: 2,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: m.serviceIconSize,
              height: m.serviceIconSize,
              child: imageUrl.isEmpty
                  ? Icon(
                      fallbackIcon,
                      size: m.serviceIconSize,
                      color: c.textPrimary,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          fallbackIcon,
                          size: m.serviceIconSize,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: m.pagePadding * 0.3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: m.serviceLabelSize,
                fontWeight: FontWeight.w500,
                height: 1.1,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
