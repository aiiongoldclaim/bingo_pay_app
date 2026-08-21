import 'package:flutter/material.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../../data/models/member_ship_model.dart';
import 'membership_formatters.dart';
import 'membership_metrices.dart';

class MembershipHeroCard extends StatelessWidget {
  const MembershipHeroCard({
    super.key,
    required this.plan,
    required this.subscription,
    required this.metrics,
    required this.activeBenefitCount,
    this.artworkAsset = 'assets/images/membership_card.png',
    this.brandLabel = 'THE VAULTS',
  });

  final MembershipPlan? plan;
  final MembershipSubscription subscription;
  final MembershipMetrics metrics;
  final int activeBenefitCount;
  final String artworkAsset;
  final String brandLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    // Hero dono theme me deep purple rehta hai -> ink white + gold.
    const onHero = ThemeColors.white;
    final onHeroMuted = onHero.withValues(alpha: 0.80);

    final goldLine = subscription.isActive
        ? 'You\u2019re a member.'
        : subscription.statusLabel;

    return Container(
      height: m.heroHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: c.isDark
            ? ThemeColors.heroBannerDark
            : ThemeColors.primaryGradient1,
        borderRadius: BorderRadius.circular(m.radiusLg),
        border: c.isDark ? Border.all(color: c.border) : null,
      ),
      child: Stack(
        children: [
          // ---- artwork (right) ----
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: m.isTabletLandscape ? m.heroHeight * 1.5 : m.heroHeight,
            child: Image.asset(
              artworkAsset,
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // ---- text (left) ----
          Padding(
            padding: EdgeInsets.all(m.cardPad),
            child: SizedBox(
              width: m.isTablet
                  ? double.infinity
                  : MediaQuery.sizeOf(context).width * 0.54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        size: m.brandWordSize * 1.35,
                        color: ThemeColors.gold1,
                      ),
                      SizedBox(width: m.cardPad * 0.35),
                      Flexible(
                        child: Text(
                          brandLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: m.brandWordSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.6,
                            color: ThemeColors.gold1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: m.rowGap),

                  Text(
                    plan?.name ?? 'Membership',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.heroTitleSize,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: onHero,
                    ),
                  ),
                  Text(
                    goldLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.heroTitleSize,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: ThemeColors.gold1,
                    ),
                  ),

                  SizedBox(height: m.rowGap * 0.7),

                  Text(
                    activeBenefitCount > 0
                        ? 'Enjoy $activeBenefitCount premium benefits on every order, every day.'
                        : 'Enjoy premium shopping benefits every day.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.heroBodySize,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: onHeroMuted,
                    ),
                  ),

                  SizedBox(height: m.rowGap),

                  Wrap(
                    spacing: m.cardPad * 0.4,
                    runSpacing: m.cardPad * 0.3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _HeroPill(
                        label: subscription.statusLabel,
                        metrics: m,
                        dotColor: subscription.isActive
                            ? c.statusSuccess
                            : c.statusWarning,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: m.smallIcon,
                            color: onHeroMuted,
                          ),
                          SizedBox(width: m.cardPad * 0.25),
                          Text(
                            'Valid till ${formatMembershipDate(subscription.endAt)}',
                            style: TextStyle(
                              fontSize: m.captionSize,
                              fontWeight: FontWeight.w500,
                              color: onHeroMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
    required this.metrics,
    required this.dotColor,
  });

  final String label;
  final MembershipMetrics metrics;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    const onHero = ThemeColors.white;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad * 0.45,
        vertical: m.cardPad * 0.22,
      ),
      decoration: BoxDecoration(
        color: onHero.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: onHero.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: m.captionSize * 0.6,
            height: m.captionSize * 0.6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: m.cardPad * 0.22),
          Text(
            label,
            style: TextStyle(
              fontSize: m.captionSize,
              fontWeight: FontWeight.w700,
              color: onHero,
            ),
          ),
        ],
      ),
    );
  }
}