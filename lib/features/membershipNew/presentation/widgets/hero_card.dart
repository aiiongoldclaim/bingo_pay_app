import 'package:flutter/material.dart';

import 'package:bingo_pay/core/constants/image_constants.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../widgets/membership_metrices.dart';

class MembershipHeroCard extends StatelessWidget {
  const MembershipHeroCard({
    super.key,
    required this.metrics,
    required this.title,
    required this.status,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.billingCycle,
    this.daysRemaining,
    this.description =
    'You’re enjoying premium benefits with The Vaults.',
    this.brandTitle = 'THE VAULTS',
    this.imageAsset = AppImages.membership,
    this.showImage = true,
  });

  final MembershipMetrics metrics;
  final String title;
  final String status;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final String billingCycle;
  final int? daysRemaining;
  final String description;
  final String brandTitle;
  final String imageAsset;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    const onHero = ThemeColors.white;

    final onHeroMuted = onHero.withValues(
      alpha: 0.78,
    );

    final hairline = onHero.withValues(
      alpha: 0.14,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: c.isDark
            ? ThemeColors.heroBannerDark
            : ThemeColors.primaryGradient1,
        borderRadius: BorderRadius.circular(
          m.radiusLg,
        ),
        border: c.isDark
            ? Border.all(
          color: c.border,
        )
            : null,
      ),
      child: Stack(
        children: [
          if (showImage)
            Positioned(
              right: -m.cardPad * 0.3,
              top: m.cardPad * 0.1,
              width: m.iconCircle * 2.7,
              height: m.iconCircle * 2.7,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
                errorBuilder: (_, __, ___) =>
                const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(
              m.cardPad,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _BrandHeader(
                  metrics: m,
                  title: brandTitle,
                ),
                SizedBox(
                  height: m.rowGap,
                ),
                _StatusBadge(
                  metrics: m,
                  status: status,
                  isActive: isActive,
                ),
                SizedBox(
                  height: m.rowGap * 0.8,
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:
                    m.heroTitleSize * 0.72,
                    fontWeight: FontWeight.w700,
                    color: onHero,
                  ),
                ),
                SizedBox(
                  height: m.rowGap * 0.35,
                ),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.heroBodySize,
                    height: 1.4,
                    color: onHeroMuted,
                  ),
                ),
                SizedBox(
                  height: m.rowGap * 1.2,
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.metrics,
    required this.title,
  });

  final MembershipMetrics metrics;
  final String title;

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.diamond_outlined,
          size: m.brandWordSize * 1.3,
          color: ThemeColors.gold1,
        ),
        SizedBox(
          width: m.cardPad * 0.35,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: m.brandWordSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
            color: ThemeColors.gold1,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.metrics,
    required this.status,
    required this.isActive,
  });

  final MembershipMetrics metrics;
  final String status;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad * 0.55,
        vertical: m.cardPad * 0.26,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? c.statusSuccess
            : c.statusWarning,
        borderRadius:
        BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive
                ? Icons.check_circle_rounded
                : Icons.info_rounded,
            size: m.captionSize * 1.25,
            color: ThemeColors.white,
          ),
          SizedBox(
            width: m.cardPad * 0.25,
          ),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: m.captionSize,
              fontWeight: FontWeight.w700,
              color: ThemeColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

