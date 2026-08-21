import 'package:flutter/material.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';

import '../../data/models/member_ship_model.dart';
import 'membership_metrices.dart';


IconData membershipEntitlementIcon(String key) => switch (key.toUpperCase()) {
  'AUCTION_BUYER_ACCESS' => Icons.gavel_rounded,
  'FREE_DELIVERY' => Icons.local_shipping_outlined,
  'DISCOUNT_PERCENT' => Icons.percent_rounded,
  'LUXE_EARLY_ACCESS' => Icons.auto_awesome_outlined,
  'ULTRA_LUXE_EARLY_ACCESS' => Icons.diamond_outlined,
  'EXCLUSIVE_ACCESS' => Icons.lock_open_rounded,
  'EARLY_ACCESS_DURATION' => Icons.timer_outlined,
  'PRIORITY_SUPPORT' => Icons.support_agent_rounded,
  'CASHBACK' => Icons.savings_outlined,
  _ => Icons.card_giftcard_rounded,
};

class MembershipBenefitTile extends StatelessWidget {
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

    final iconBg = enabled ? c.brandSoft : c.surfaceAlt;
    final iconColor = enabled ? c.brand : c.textMuted;
    final titleColor = enabled ? c.textPrimary : c.textSecondary;

    return Container(
      padding: EdgeInsets.all(m.cardPad * 0.72),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.radiusMd),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: m.iconBox,
            height: m.iconBox,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(m.radiusSm),
            ),
            child: Icon(
              membershipEntitlementIcon(entitlement.key),
              size: m.iconSize,
              color: iconColor,
            ),
          ),
          SizedBox(width: m.cardPad * 0.6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entitlement.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.tileTitleSize,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: m.rowGap * 0.18),
                Text(
                  entitlement.valueLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.tileValueSize,
                    fontWeight: FontWeight.w500,
                    color: enabled ? c.textSecondary : c.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: m.cardPad * 0.35),
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            size: m.badgeIcon,
            color: enabled ? c.statusSuccess : c.textMuted,
          ),
        ],
      ),
    );
  }
}