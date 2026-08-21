import 'package:flutter/material.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';

import '../../data/models/member_ship_model.dart';
import 'membership_formatters.dart';
import 'membership_metrices.dart';


class MembershipDetailsCard extends StatelessWidget {
  const MembershipDetailsCard({
    super.key,
    required this.plan,
    required this.subscription,
    required this.metrics,
  });

  final MembershipPlan? plan;
  final MembershipSubscription subscription;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final rows = <Widget>[
      if (plan != null)
        MembershipDetailRow(
          label: 'Plan',
          value: plan!.name,
          metrics: m,
        ),
      if (plan != null)
        MembershipDetailRow(
          label: 'Membership type',
          value: plan!.kindLabel,
          metrics: m,
        ),
      MembershipDetailRow(
        label: 'Reference',
        value: subscription.reference,
        metrics: m,
      ),
      MembershipDetailRow(
        label: 'Billing cycle',
        value: subscription.billingCycleLabel,
        metrics: m,
      ),
      MembershipDetailRow(
        label: 'Amount',
        value: subscription.priceLabel,
        metrics: m,
      ),
      MembershipDetailRow(
        label: 'Started on',
        value: formatMembershipDate(subscription.startAt),
        metrics: m,
      ),
      MembershipDetailRow(
        label: 'Expires on',
        value: formatMembershipDate(subscription.endAt),
        metrics: m,
      ),
      MembershipDetailRow(
        label: 'Auto renew',
        metrics: m,
        valueWidget: MembershipTonePill(
          label: subscription.autoRenew ? 'On' : 'Off',
          metrics: m,
          foreground: subscription.autoRenew
              ? c.statusSuccess
              : c.textSecondary,
          background: subscription.autoRenew
              ? c.statusSuccessSoft
              : c.surfaceAlt,
        ),
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad,
        vertical: m.cardPad * 0.35,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.radiusMd),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) Divider(height: 1, color: c.border),
          ],
        ],
      ),
    );
  }
}

class MembershipDetailRow extends StatelessWidget {
  const MembershipDetailRow({
    super.key,
    required this.label,
    required this.metrics,
    this.value,
    this.valueWidget,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: m.rowGap * 0.62),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: m.labelSize,
                fontWeight: FontWeight.w500,
                color: c.textSecondary,
              ),
            ),
          ),
          SizedBox(width: m.cardPad * 0.4),
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child:
              valueWidget ??
                  Text(
                    value ?? '--',
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.labelSize,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class MembershipTonePill extends StatelessWidget {
  const MembershipTonePill({
    super.key,
    required this.label,
    required this.metrics,
    required this.foreground,
    required this.background,
  });

  final String label;
  final MembershipMetrics metrics;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad * 0.4,
        vertical: m.cardPad * 0.16,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: m.captionSize,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}