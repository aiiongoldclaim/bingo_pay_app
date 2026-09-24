import 'package:flutter/material.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';

import '../../data/models/member_ship_model.dart';
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
    final colors = context.c;
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
        color: colors.surface,
        borderRadius: BorderRadius.circular(
          m.radiusLg,
        ),
        border: Border.all(
          color: colors.border,
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
              color: colors.textPrimary,
            ),
          ),
          SizedBox(
            height: m.rowGap,
          ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: m.rowGap * 0.65),
            MembershipBenefitTile(
              entitlement: items[i],
              metrics: m,
            ),
          ],
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
    final colors = context.c;
    final m = metrics;
    final enabled = entitlement.enabled;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          enabled ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
          size: m.badgeIcon,
          color: enabled ? colors.statusSuccess : colors.textMuted,
        ),
        SizedBox(width: m.cardPad * 0.5),
        Expanded(
          child: Text(
            '${entitlement.name} — ${entitlement.valueLabel}',
            style: TextStyle(
              fontSize: m.bodySize,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: enabled ? colors.textPrimary : colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}