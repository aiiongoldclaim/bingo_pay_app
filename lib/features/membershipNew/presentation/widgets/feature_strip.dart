import 'package:flutter/material.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';

import '../../data/models/membership_plan_model.dart';
import 'benifits_tile.dart';
import 'landing_widgets.dart';
import 'membership_metrices.dart';

class MembershipFeatureStrip extends StatelessWidget {
  const MembershipFeatureStrip({
    super.key,
    required this.features,
    required this.metrics,
    this.filled = false,
  });

  final List<MembershipPlanFeature> features;
  final MembershipMetrics metrics;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    if (features.isEmpty) return const SizedBox.shrink();

    Widget cell(MembershipPlanFeature f) => _FeatureCell(feature: f, metrics: m);
    Widget vDivider() => Container(width: 1, color: c.border);

    Widget content;

    if (m.stripTwoByTwo && features.length > 2) {
      final rows = <Widget>[];
      for (var i = 0; i < features.length; i += 2) {
        final left = features[i];
        final right = (i + 1 < features.length) ? features[i + 1] : null;

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
        if (i + 2 < features.length) {
          rows.add(Divider(height: 1, color: c.border));
        }
      }
      content = Column(children: rows);
    } else {
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < features.length; i++) ...[
              Expanded(child: cell(features[i])),
              if (i != features.length - 1) vDivider(),
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

class _FeatureCell extends StatelessWidget {
  const _FeatureCell({required this.feature, required this.metrics});

  final MembershipPlanFeature feature;
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
            icon: membershipEntitlementIcon(feature.key),
            metrics: m,
          ),
          SizedBox(height: m.rowGap * 0.55),
          Text(
            feature.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: m.labelSize,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: m.rowGap * 0.25),
          Text(
            feature.valueLabel,
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