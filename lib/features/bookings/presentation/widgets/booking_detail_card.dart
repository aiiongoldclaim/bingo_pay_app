import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'booking_details_metrics.dart';

class BookingDetailCard extends StatelessWidget {
  const BookingDetailCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(
          color: colors.border,
        ),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(
                    alpha: 0.035,
                  ),
                  blurRadius: m.cardShadowBlur,
                  offset: Offset(0, m.cardShadowOffsetY),
                ),
              ],
      ),
      child: child,
    );
  }
}

class BookingDetailRow extends StatelessWidget {
  const BookingDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Row(
      children: [
        Container(
          width: m.detailIconBox,
          height: m.detailIconBox,
          decoration: BoxDecoration(
            color: colors.brandSoft,
            borderRadius:
                BorderRadius.circular(m.detailIconRadius),
          ),
          child: Icon(
            icon,
            size: m.detailIconSize,
            color: colors.brand,
          ),
        ),
        SizedBox(width: m.detailGapW),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontFamily: 'Inter',
              fontSize: m.detailLabelSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: m.detailGapW),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontFamily: 'Inter',
              fontSize: m.detailValueSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class BookingDetailDivider extends StatelessWidget {
  const BookingDetailDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: m.dividerVPad,
      ),
      child: Container(
        height: 1,
        color: colors.border,
      ),
    );
  }
}
