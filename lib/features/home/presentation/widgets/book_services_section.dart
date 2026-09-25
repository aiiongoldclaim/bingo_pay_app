import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../models/vault_theme_colors.dart';
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
    this.activeTheme,
  });

  final HomeMetrics metrics;
  final String title;
  final String subtitle;
  final String buttonText;

  final List<ServiceEntity> services;
  final int maxTiles;
  final String viewAllLabel;
  final ValueChanged<ServiceEntity>? onServiceTap;
  final VoidCallback? onViewAll;
  final String Function(ServiceEntity)? subtitleBuilder;

  final VaultThemeColors? activeTheme;

  static const _animationDuration = Duration(milliseconds: 350);
  static const _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    final colors = context.c;
    final theme = activeTheme;
    final visible = services.take(maxTiles).toList();

    return AnimatedContainer(
      duration: _animationDuration,
      curve: _animationCurve,
      padding: EdgeInsets.all(metrics.pagePadding),
      decoration: BoxDecoration(
        color: theme?.sectionBackground ?? colors.servicesBg,
        borderRadius: BorderRadius.circular(metrics.heroRadius * 0.75),
        border: theme != null
            ? Border.all(color: theme.border)
            : (colors.isDark ? Border.all(color: colors.border) : null),
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
            activeTheme: theme,
          ),
          SizedBox(height: metrics.pagePadding * 0.9),
          _ServicesRow(
            metrics: metrics,
            services: visible,
            buttonText: buttonText,
            onServiceTap: onServiceTap,
            subtitleBuilder: subtitleBuilder,
            activeTheme: theme,
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
    required this.activeTheme,
  });

  final HomeMetrics metrics;
  final String title;
  final String subtitle;
  final String viewAllLabel;
  final VoidCallback? onViewAll;
  final VaultThemeColors? activeTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final theme = activeTheme;
    final headingColor = theme?.text ?? colors.brand;
    final actionColor = theme?.button ?? colors.brand;

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
                  color: headingColor,
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
                  color: theme?.secondaryText ?? colors.textSecondary,
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
                      color: actionColor,
                    ),
                  ),
                  SizedBox(width: metrics.pagePadding * 0.15),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: metrics.serviceLabelSize * 1.6,
                    color: actionColor,
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
    required this.activeTheme,
  });

  final HomeMetrics metrics;
  final List<ServiceEntity> services;
  final String buttonText;
  final ValueChanged<ServiceEntity>? onServiceTap;
  final String Function(ServiceEntity)? subtitleBuilder;
  final VaultThemeColors? activeTheme;

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

        final cardHeight = cardPad * 2 +
            imageSize +
            cardPad * 0.9 +
            titleHeight +
            (hasDescription ? cardPad * 0.4 + descriptionHeight : 0.0) +
            cardPad * 0.6 +
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
            activeTheme: activeTheme,
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
    required this.activeTheme,
  });

  final HomeMetrics metrics;
  final double width;
  final ServiceEntity service;
  final String buttonText;
  final String description;
  final bool reserveDescriptionSpace;
  final VoidCallback? onTap;
  final VaultThemeColors? activeTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final theme = activeTheme;
    final pad = metrics.pagePadding * 0.5;

    return SizedBox(
      width: width,
      child: Material(
        color: theme?.cardBackground ?? colors.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme?.border ?? colors.border),
            ),
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardImage(
                  colors: colors,
                  activeTheme: theme,
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
                    color: theme?.text ?? colors.textPrimary,
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
                        color: theme?.secondaryText ?? colors.textSecondary,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),

                SizedBox(height: pad * 0.6),

                theme != null
                    ? SizedBox(
                        width: double.infinity,
                        height: metrics.searchHeight * 0.62,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.button,
                            foregroundColor: theme.buttonText,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              buttonText,
                              style: TextStyle(
                                fontSize: metrics.serviceLabelSize * 1.05,
                                fontWeight: FontWeight.w600,
                                color: theme.buttonText,
                              ),
                            ),
                          ),
                        ),
                      )
                    : AppButton(
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
    this.activeTheme,
  });

  final AppThemeColors colors;
  final String imageUrl;
  final double placeholderSize;
  final VaultThemeColors? activeTheme;

  @override
  Widget build(BuildContext context) {
    final theme = activeTheme;

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: theme?.sectionBackground ?? colors.surfaceAlt,
          child: imageUrl.isEmpty
              ? Icon(
            Icons.design_services_outlined,
            size: placeholderSize,
            color: theme?.secondaryText ?? colors.textMuted,
          )
              : Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.design_services_outlined,
              size: placeholderSize,
              color: theme?.secondaryText ?? colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}