import 'package:flutter/material.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'membership_metrices.dart';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class MembershipDetailsCard extends StatelessWidget {
  const MembershipDetailsCard({
    super.key,
    required this.metrics,
    required this.items,
    this.title = 'Membership Details',
  });

  final MembershipMetrics metrics;
  final List<MembershipDetailItem> items;
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

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
            height: m.rowGap * 0.6,
          ),
          for (int i = 0; i < items.length; i++) ...[
            MembershipDetailRow(
              item: items[i],
              metrics: m,
            ),
            if (i != items.length - 1)
              Divider(
                height: 1,
                color: c.border,
              ),
          ],
        ],
      ),
    );
  }
}

class MembershipDetailItem {
  const MembershipDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class MembershipDetailRow extends StatelessWidget {
  const MembershipDetailRow({
    super.key,
    required this.item,
    required this.metrics,
  });

  final MembershipDetailItem item;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: m.rowGap * 0.55,
      ),
      child: Row(
        children: [
          Container(
            width: m.iconCircle * 0.6,
            height: m.iconCircle * 0.6,
            decoration: BoxDecoration(
              color: c.brandSoft,
              borderRadius: BorderRadius.circular(
                m.radiusSm,
              ),
            ),
            child: Icon(
              item.icon,
              size: m.iconSize * 0.7,
              color: c.brand,
            ),
          ),
          SizedBox(
            width: m.cardPad * 0.5,
          ),
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: m.labelSize,
                fontWeight: FontWeight.w500,
                color: c.textPrimary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              item.value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.labelSize,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatMembershipDate(DateTime? date) {
  if (date == null) return '--';

  final day = date.day.toString().padLeft(2, '0');

  return '$day ${_months[date.month - 1]} ${date.year}';
}

String formatMembershipMonth(DateTime? date) {
  if (date == null) return '--';

  return '${_months[date.month - 1]} ${date.year}';
}

String formatDaysLeft(int days) {
  if (days <= 0) return 'Expires today';
  if (days == 1) return '1 day left';

  return '$days days left';
}