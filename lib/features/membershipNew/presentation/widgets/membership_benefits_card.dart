import 'package:flutter/material.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';

import '../../data/models/member_ship_model.dart';
import '../screens/membership_screen.dart';
import 'membership_metrices.dart';

class MembershipBenefitsCard extends StatelessWidget {
  const MembershipBenefitsCard({
    super.key,
    required this.entitlements,
    required this.metrics,
    this.title = 'Your Membership Benefits',
    this.columns,
  });

  final List<MembershipEntitlement> entitlements;
  final MembershipMetrics metrics;
  final String title;
  final int? columns;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    if (entitlements.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = [...entitlements]
      ..sort((a, b) {
        if (a.enabled == b.enabled) {
          return 0;
        }

        return a.enabled ? -1 : 1;
      });

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(
          m.radiusLg,
        ),
        border: Border.all(
          color: c.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: m.sectionTitleSize,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          SizedBox(
            height: m.rowGap,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemColumns =
                  columns ??
                      (m.isTablet ? 4 : 3);

              final itemWidth =
                  (constraints.maxWidth -
                      m.tileGap *
                          (itemColumns - 1)) /
                      itemColumns;

              return Wrap(
                spacing: m.tileGap,
                runSpacing: m.tileGap,
                children: [
                  for (final entitlement in items)
                    SizedBox(
                      width: itemWidth,
                      child: MembershipBenefitTile(
                        entitlement: entitlement,
                        metrics: m,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class MembershipBenefitTile
    extends StatelessWidget {
  const MembershipBenefitTile({
    super.key,
    required this.entitlement,
    required this.metrics,
  });

  final MembershipEntitlement entitlement;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final enabled = entitlement.enabled;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad * 0.4,
        vertical: m.cardPad * 0.7,
      ),
      decoration: BoxDecoration(
        color: enabled
            ? c.surfaceAlt
            : c.surface,
        borderRadius: BorderRadius.circular(
          m.radiusMd,
        ),
        border: Border.all(
          color: c.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: m.iconCircle * 0.78,
            height: m.iconCircle * 0.78,
            decoration: BoxDecoration(
              color: enabled
                  ? c.brandSoft
                  : c.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icon(entitlement.key),
              size: m.iconSize * 0.9,
              color: enabled
                  ? c.brand
                  : c.textMuted,
            ),
          ),
          SizedBox(
            height: m.rowGap * 0.5,
          ),
          Text(
            entitlement.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: m.captionSize * 1.05,
              fontWeight: FontWeight.w700,
              color: enabled
                  ? c.textPrimary
                  : c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(String key) {
    return switch (key.toUpperCase()) {
      'AUCTION_BUYER_ACCESS' =>
      Icons.gavel_rounded,
      'FREE_DELIVERY' =>
      Icons.local_shipping_outlined,
      'DISCOUNT_PERCENT' =>
      Icons.local_offer_outlined,
      'LUXE_EARLY_ACCESS' =>
      Icons.access_time_rounded,
      'ULTRA_LUXE_EARLY_ACCESS' =>
      Icons.diamond_outlined,
      'EXCLUSIVE_ACCESS' =>
      Icons.workspace_premium_outlined,
      'EARLY_ACCESS_DURATION' =>
      Icons.timer_outlined,
      _ =>
      Icons.card_giftcard_rounded,
    };
  }
}