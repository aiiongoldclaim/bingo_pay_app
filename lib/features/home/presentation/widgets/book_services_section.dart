// import 'package:flutter/material.dart';
//
// import '../../../../core/theme/app_theme_colors.dart';
// import '../../../services/domain/entities/service_entity.dart';
// import 'home_metrics.dart';
//
// class BookServicesSection extends StatelessWidget {
//   const BookServicesSection({
//     super.key,
//     required this.metrics,
//     required this.title,
//     required this.subtitle,
//     required this.buttonText,
//     required this.services,
//     this.maxTiles = 4,
//     this.viewAllLabel = 'View All',
//     this.onBookNow,
//     this.onServiceTap,
//     this.onViewAll,
//   });
//
//   final HomeMetrics metrics;
//   final String title;
//   final String subtitle;
//   final String buttonText;
//   final List<ServiceEntity> services;
//   final int maxTiles;
//   final String viewAllLabel;
//   final VoidCallback? onBookNow;
//   final ValueChanged<ServiceEntity>? onServiceTap;
//   final VoidCallback? onViewAll;
//
//   @override
//   Widget build(BuildContext context) {
//     if (services.isEmpty) return const SizedBox.shrink();
//     final c = context.c;
//     final m = metrics;
//
//     final visible = services.take(maxTiles).toList();
//     final tileCount = visible.length + 1; // +1 = View All tile
//
//     return Container(
//       padding: EdgeInsets.all(m.pagePadding),
//       decoration: BoxDecoration(
//         color: c.servicesBg,
//         borderRadius: BorderRadius.circular(m.heroRadius * 0.75),
//         border: c.isDark ? Border.all(color: c.border) : null,
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final gap = m.pagePadding * 0.4;
//
//           // Left text column: phone pe ~40%, tablet pe ~30%
//           final leftWidth = constraints.maxWidth * (m.isTablet ? 0.30 : 0.38);
//           final rightWidth =
//               constraints.maxWidth - leftWidth - m.pagePadding * 0.5;
//
//           // Tile width available space se derive — HARDCODED NAHI
//           final rawTileWidth = (rightWidth - gap * (tileCount - 1)) / tileCount;
//           final scrollable = rawTileWidth < m.serviceTileMinWidth;
//           final tileWidth = scrollable ? m.serviceTileMinWidth : rawTileWidth;
//
//           final tiles = <Widget>[
//             ...visible.map(
//               (s) => _ServiceTile(
//                 metrics: m,
//                 width: tileWidth,
//                 label: s.title,
//                 imageUrl: s.imageUrl,
//                 onTap: () => onServiceTap?.call(s),
//               ),
//             ),
//             _ServiceTile(
//               metrics: m,
//               width: tileWidth,
//               label: viewAllLabel,
//               imageUrl: '',
//               fallbackIcon: Icons.grid_view_rounded,
//               onTap: onViewAll,
//             ),
//           ];
//
//           final tileHeight =
//               m.serviceIconSize +
//               m.serviceLabelSize * 1.4 +
//               m.pagePadding * 1.3;
//
//           return Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // ── Left: heading + CTA ─────────────────────
//               SizedBox(
//                 width: leftWidth,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       title.toUpperCase(),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: m.sectionTitleSize * 0.8,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.3,
//                         height: 1.2,
//                         color: c.brand,
//                       ),
//                     ),
//                     SizedBox(height: m.pagePadding * 0.3),
//                     Text(
//                       subtitle,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: m.serviceLabelSize * 1.1,
//                         height: 1.3,
//                         color: c.textSecondary,
//                       ),
//                     ),
//                     SizedBox(height: m.pagePadding * 0.6),
//                     SizedBox(
//                       height: m.searchHeight * 0.66,
//                       child: ElevatedButton(
//                         onPressed: onBookNow,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: c.brand,
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           minimumSize: Size.zero,
//                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           padding: EdgeInsets.symmetric(
//                             horizontal: m.pagePadding * 0.7,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                         child: FittedBox(
//                           fit: BoxFit.scaleDown,
//                           child: Text(
//                             buttonText.toUpperCase(),
//                             style: TextStyle(
//                               fontSize: m.serviceLabelSize * 1.1,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(width: m.pagePadding * 0.5),
//
//               // ── Right: service tiles ────────────────────
//               SizedBox(
//                 width: rightWidth,
//                 height: tileHeight,
//                 child: scrollable
//                     ? ListView.separated(
//                         scrollDirection: Axis.horizontal,
//                         padding: EdgeInsets.zero,
//                         itemCount: tiles.length,
//                         separatorBuilder: (_, __) => SizedBox(width: gap),
//                         itemBuilder: (_, i) => tiles[i],
//                       )
//                     : Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: tiles,
//                       ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _ServiceTile extends StatelessWidget {
//   const _ServiceTile({
//     required this.metrics,
//     required this.width,
//     required this.label,
//     required this.imageUrl,
//     this.fallbackIcon = Icons.design_services_outlined,
//     this.onTap,
//   });
//
//   final HomeMetrics metrics;
//   final double width;
//   final String label;
//   final String imageUrl;
//   final IconData fallbackIcon;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         width: width,
//         padding: EdgeInsets.symmetric(
//           vertical: m.pagePadding * 0.45,
//           horizontal: 2,
//         ),
//         decoration: BoxDecoration(
//           color: c.surface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: c.border),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: m.serviceIconSize,
//               height: m.serviceIconSize,
//               child: imageUrl.isEmpty
//                   ? Icon(
//                       fallbackIcon,
//                       size: m.serviceIconSize,
//                       color: c.textPrimary,
//                     )
//                   : ClipRRect(
//                       borderRadius: BorderRadius.circular(4),
//                       child: Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => Icon(
//                           fallbackIcon,
//                           size: m.serviceIconSize,
//                           color: c.textPrimary,
//                         ),
//                       ),
//                     ),
//             ),
//             SizedBox(height: m.pagePadding * 0.3),
//             Text(
//               label,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: m.serviceLabelSize,
//                 fontWeight: FontWeight.w500,
//                 height: 1.1,
//                 color: c.textPrimary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
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
    this.onServiceTap,
    this.onViewAll,
    this.subtitleBuilder,
  });

  final HomeMetrics metrics;
  final String title;
  final String subtitle;

  /// Har card ke button ka label (e.g. 'Book Now')
  final String buttonText;

  final List<ServiceEntity> services;
  final int maxTiles;
  final String viewAllLabel;

  /// Card ya BOOK NOW — dono isi ko call karte hain
  final ValueChanged<ServiceEntity>? onServiceTap;
  final VoidCallback? onViewAll;

  /// Card ke andar description line. Na do to blank rahegi.
  final String Function(ServiceEntity)? subtitleBuilder;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    final colors = context.c;
    final visible = services.take(maxTiles).toList();

    return Container(
      padding: EdgeInsets.all(metrics.pagePadding),
      decoration: BoxDecoration(
        color: colors.servicesBg,
        borderRadius: BorderRadius.circular(metrics.heroRadius * 0.75),
        border: colors.isDark ? Border.all(color: colors.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SectionHeader(
            metrics: metrics,
            title: title,
            subtitle: subtitle,
            viewAllLabel: viewAllLabel,
            onViewAll: onViewAll,
          ),
          SizedBox(height: metrics.pagePadding * 0.9),
          _ServicesRow(
            metrics: metrics,
            services: visible,
            buttonText: buttonText,
            onServiceTap: onServiceTap,
            subtitleBuilder: subtitleBuilder,
          ),
        ],
      ),
    );
  }
}

// ── Header: title + subtitle | VIEW ALL ────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.metrics,
    required this.title,
    required this.subtitle,
    required this.viewAllLabel,
    required this.onViewAll,
  });

  final HomeMetrics metrics;
  final String title;
  final String subtitle;
  final String viewAllLabel;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: metrics.sectionTitleSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  height: 1.15,
                  color: colors.brand,
                ),
              ),
              SizedBox(height: metrics.pagePadding * 0.25),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: metrics.serviceLabelSize * 1.15,
                  height: 1.25,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.pagePadding * 0.3,
                vertical: metrics.pagePadding * 0.2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewAllLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: metrics.serviceLabelSize * 1.1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: colors.brand,
                    ),
                  ),
                  SizedBox(width: metrics.pagePadding * 0.15),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: metrics.serviceLabelSize * 1.6,
                    color: colors.brand,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Cards row (fit ho to Row, warna horizontal scroll) ─────────────────────
class _ServicesRow extends StatelessWidget {
  const _ServicesRow({
    required this.metrics,
    required this.services,
    required this.buttonText,
    required this.onServiceTap,
    required this.subtitleBuilder,
  });

  final HomeMetrics metrics;
  final List<ServiceEntity> services;
  final String buttonText;
  final ValueChanged<ServiceEntity>? onServiceTap;
  final String Function(ServiceEntity)? subtitleBuilder;

  @override

  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = metrics.pagePadding * 0.6;
        final count = services.length;

        final rawWidth = (constraints.maxWidth - gap * (count - 1)) / count;
        final minWidth = metrics.isTablet ? 200.0 : 150.0;
        final scrollable = rawWidth < minWidth;
        final cardWidth = scrollable ? minWidth : rawWidth;

        final descriptions = services
            .map((service) => subtitleBuilder?.call(service) ?? '')
            .toList();
        final hasDescription = descriptions.any((text) => text.isNotEmpty);

        final cardPad = metrics.pagePadding * 0.5;
        final imageSize = cardWidth - cardPad * 2;
        final titleHeight = metrics.serviceLabelSize * 1.3 * 1.2;
        final descriptionHeight =
        hasDescription ? metrics.serviceLabelSize * 1.3 * 2 : 0.0;
        final buttonHeight = metrics.searchHeight * 0.62;

        final cardHeight = cardPad * 2 +          // container padding
            imageSize +                            // square image
            cardPad * 0.9 +                        // image → title gap
            titleHeight +
            (hasDescription ? cardPad * 0.4 + descriptionHeight : 0.0) +
            cardPad * 0.6 +                        // → button gap
            buttonHeight;

        final cards = List.generate(
          services.length,
              (index) => _ServiceCard(
            metrics: metrics,
            width: cardWidth,
            service: services[index],
            buttonText: buttonText,
            description: descriptions[index],
            reserveDescriptionSpace: hasDescription,
            onTap: onServiceTap == null
                ? null
                : () => onServiceTap!(services[index]),
          ),
        );

        return SizedBox(
          height: cardHeight,
          child: scrollable
              ? ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: cards.length,
            separatorBuilder: (_, __) => SizedBox(width: gap),
            itemBuilder: (_, index) => cards[index],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: cards,
          ),
        );
      },
    );
  }
}

// ── Single card ────────────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.metrics,
    required this.width,
    required this.service,
    required this.buttonText,
    required this.description,
    required this.onTap,
    required this.reserveDescriptionSpace,
  });

  final HomeMetrics metrics;
  final double width;
  final ServiceEntity service;
  final String buttonText;
  final String description;
  final bool reserveDescriptionSpace;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final pad = metrics.pagePadding * 0.5;

    return SizedBox(
      width: width,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardImage(
                  colors: colors,
                  imageUrl: service.imageUrl,
                  placeholderSize: metrics.serviceIconSize * 1.15,
                ),

                SizedBox(height: pad * 0.9),

                Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: metrics.serviceLabelSize * 1.3,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: colors.textPrimary,
                  ),
                ),

                if (reserveDescriptionSpace) ...[
                  SizedBox(height: pad * 0.4),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: metrics.serviceLabelSize,
                        height: 1.3,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),

                SizedBox(height: pad * 0.6),

                AppButton(
                  label: buttonText,
                  onPressed: onTap,
                  height: metrics.searchHeight * 0.62,
                  fontSize: metrics.serviceLabelSize * 1.05,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Image ──────────────────────────────────────────────────────────────────
class _CardImage extends StatelessWidget {
  const _CardImage({
    required this.colors,
    required this.imageUrl,
    required this.placeholderSize,
  });

  final AppThemeColors colors;
  final String imageUrl;
  final double placeholderSize;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: colors.surfaceAlt,
          child: imageUrl.isEmpty
              ? Icon(
            Icons.design_services_outlined,
            size: placeholderSize,
            color: colors.textMuted,
          )
              : Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.design_services_outlined,
              size: placeholderSize,
              color: colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}