import 'package:flutter/material.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../../data/models/member_ship_model.dart';

import 'benifits_tile.dart';
import 'membership_metrices.dart';

class MembershipSectionHeader extends StatelessWidget {
  const MembershipSectionHeader({
    super.key,
    required this.title,
    required this.metrics,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final MembershipMetrics metrics;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: m.sectionTitleSize,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(m.radiusSm),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: m.cardPad * 0.2,
                vertical: m.cardPad * 0.15,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: m.labelSize,
                      fontWeight: FontWeight.w600,
                      color: c.brand,
                    ),
                  ),
                  SizedBox(width: m.cardPad * 0.15),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: m.smallIcon,
                    color: c.brand,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// benefits strip — 4 icon columns with vertical dividers (image jaisa)
// entitlements se banta hai
// ---------------------------------------------------------------------------

class MembershipBenefitsStrip extends StatelessWidget {
  const MembershipBenefitsStrip({
    super.key,
    required this.items,
    required this.metrics,
    this.filled = false,
  });

  final List<MembershipEntitlement> items;
  final MembershipMetrics metrics;

  /// true -> soft surface background
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    if (items.isEmpty) return const SizedBox.shrink();

    Widget cell(MembershipEntitlement e) =>
        _BenefitStripCell(entitlement: e, metrics: m);
    Widget vDivider() => Container(width: 1, color: c.border);

    Widget content;

    if (m.stripTwoByTwo && items.length > 2) {
      final rows = <Widget>[];
      for (var i = 0; i < items.length; i += 2) {
        final left = items[i];
        final right = (i + 1 < items.length) ? items[i + 1] : null;

        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cell(left)),
                vDivider(),
                Expanded(
                  child: right == null ? const SizedBox.shrink() : cell(right),
                ),
              ],
            ),
          ),
        );
        if (i + 2 < items.length) {
          rows.add(Divider(height: 1, color: c.border));
        }
      }
      content = Column(children: rows);
    } else {
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(child: cell(items[i])),
              if (i != items.length - 1) vDivider(),
            ],
          ],
        ),
      );
    }

    if (!filled) return content;

    return Container(
      padding: EdgeInsets.symmetric(vertical: m.cardPad * 0.4),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(m.radiusMd),
      ),
      child: content,
    );
  }
}

class _BenefitStripCell extends StatelessWidget {
  const _BenefitStripCell({required this.entitlement, required this.metrics});

  final MembershipEntitlement entitlement;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad * 0.4,
        vertical: m.cardPad * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MembershipIconCircle(
            icon: membershipEntitlementIcon(entitlement.key),
            metrics: m,
          ),
          SizedBox(height: m.rowGap * 0.55),
          Text(
            entitlement.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: m.labelSize,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: m.rowGap * 0.25),
          Text(
            entitlement.valueLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: m.captionSize,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// icon circle (soft brand bg + outlined icon)
// ---------------------------------------------------------------------------

class MembershipIconCircle extends StatelessWidget {
  const MembershipIconCircle({
    super.key,
    required this.icon,
    required this.metrics,
    this.size,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final MembershipMetrics metrics;
  final double? size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final box = size ?? m.iconCircle;

    return Container(
      width: box,
      height: box,
      decoration: BoxDecoration(
        color: background ?? c.brandSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size != null ? size! * 0.46 : m.circleIconSize,
        color: foreground ?? c.brand,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// plan row card (image ke "Annual / Monthly" cards jaisa)
// ---------------------------------------------------------------------------

class MembershipPlanRowCard extends StatelessWidget {
  const MembershipPlanRowCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.selected,
    required this.metrics,
    this.badge,
    this.subLine,
    this.trailingTag,
    this.trailingTagColor,
    this.trailingTagBackground,
    this.onTap,
  });

  final String title;
  final String price;
  final String period;
  final bool selected;
  final MembershipMetrics metrics;
  final String? badge;
  final String? subLine;
  final String? trailingTag;
  final Color? trailingTagColor;
  final Color? trailingTagBackground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.radiusMd),
      child: Container(
        padding: EdgeInsets.all(m.cardPad),
        decoration: BoxDecoration(
          color: selected ? c.brandSoft.withValues(alpha: 0.35) : c.surface,
          borderRadius: BorderRadius.circular(m.radiusMd),
          border: Border.all(
            color: selected ? c.brand : c.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MembershipRadio(selected: selected, metrics: m),
            SizedBox(width: m.cardPad * 0.7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: m.sectionTitleSize,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: m.cardPad * 0.4),
                        MembershipTag(
                          label: badge!,
                          metrics: m,
                          background: c.brandSoft,
                          foreground: c.brand,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: m.rowGap * 0.5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: m.priceSize,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                      SizedBox(width: m.cardPad * 0.2),
                      Flexible(
                        child: Text(
                          period,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: m.labelSize,
                            fontWeight: FontWeight.w500,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subLine != null) ...[
                    SizedBox(height: m.rowGap * 0.35),
                    Text(
                      subLine!,
                      style: TextStyle(
                        fontSize: m.captionSize,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: m.cardPad * 0.4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (trailingTag != null) ...[
                  MembershipTag(
                    label: trailingTag!,
                    metrics: m,
                    background: trailingTagBackground ?? c.brand,
                    foreground: trailingTagColor ?? ThemeColors.white,
                  ),
                  SizedBox(height: m.rowGap * 0.6),
                ],
                Text(
                  price,
                  style: TextStyle(
                    fontSize: m.sectionTitleSize,
                    fontWeight: FontWeight.w700,
                    color: c.brand,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// info strip (Secure Payment / All Major Cards / Cancel Anytime)
// ---------------------------------------------------------------------------

class MembershipInfoItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const MembershipInfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

const List<MembershipInfoItem> kMembershipTrustItems = [
  MembershipInfoItem(
    icon: Icons.verified_user_outlined,
    title: 'Secure Payment',
    subtitle: '100% safe & secure payments',
  ),
  MembershipInfoItem(
    icon: Icons.credit_card_outlined,
    title: 'All Major Cards',
    subtitle: 'Debit, Credit & UPI accepted',
  ),
  MembershipInfoItem(
    icon: Icons.cancel_outlined,
    title: 'Cancel Anytime',
    subtitle: 'No questions asked',
  ),
];

class MembershipInfoStrip extends StatelessWidget {
  const MembershipInfoStrip({
    super.key,
    required this.metrics,
    this.items = kMembershipTrustItems,
  });

  final MembershipMetrics metrics;
  final List<MembershipInfoItem> items;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad * 0.5,
        vertical: m.cardPad * 0.8,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.radiusMd),
        border: Border.all(color: c.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.35),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MembershipIconCircle(
                        icon: items[i].icon,
                        metrics: m,
                        size: m.iconCircle * 0.62,
                      ),
                      SizedBox(width: m.cardPad * 0.35),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              items[i].title,
                              style: TextStyle(
                                fontSize: m.captionSize,
                                fontWeight: FontWeight.w700,
                                color: c.textPrimary,
                              ),
                            ),
                            SizedBox(height: m.rowGap * 0.2),
                            Text(
                              items[i].subtitle,
                              style: TextStyle(
                                fontSize: m.captionSize * 0.94,
                                fontWeight: FontWeight.w400,
                                height: 1.35,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i != items.length - 1) Container(width: 1, color: c.border),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// footer link row  ("Already a member? Sign in  >")
// ---------------------------------------------------------------------------

class MembershipFooterLinkRow extends StatelessWidget {
  const MembershipFooterLinkRow({
    super.key,
    required this.leadingText,
    required this.linkText,
    required this.metrics,
    this.onTap,
  });

  final String leadingText;
  final String linkText;
  final MembershipMetrics metrics;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.radiusSm),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: m.rowGap * 0.5),
        child: Row(
          children: [
            Flexible(
              child: Text(
                leadingText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: m.labelSize,
                  fontWeight: FontWeight.w400,
                  color: c.textSecondary,
                ),
              ),
            ),
            SizedBox(width: m.cardPad * 0.2),
            Text(
              linkText,
              style: TextStyle(
                fontSize: m.labelSize,
                fontWeight: FontWeight.w700,
                color: c.brand,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: m.smallIcon,
              color: c.brand,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// small pieces
// ---------------------------------------------------------------------------

class MembershipTag extends StatelessWidget {
  const MembershipTag({
    super.key,
    required this.label,
    required this.metrics,
    required this.background,
    required this.foreground,
  });

  final String label;
  final MembershipMetrics metrics;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad * 0.45,
        vertical: m.cardPad * 0.2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(m.radiusSm),
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

class MembershipRadio extends StatelessWidget {
  const MembershipRadio({
    super.key,
    required this.selected,
    required this.metrics,
  });

  final bool selected;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      width: m.radioSize,
      height: m.radioSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.brand : c.border,
          width: selected ? 2 : 1.4,
        ),
      ),
      child: selected
          ? Center(
        child: Container(
          width: m.radioSize * 0.5,
          height: m.radioSize * 0.5,
          decoration: BoxDecoration(
            color: c.brand,
            shape: BoxShape.circle,
          ),
        ),
      )
          : null,
    );
  }
}