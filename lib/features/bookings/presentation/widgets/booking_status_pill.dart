import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'booking_details_metrics.dart';

/// Text-only status pill used on the Booking Details screen.
///
/// Distinct from [StatusBadge] (widgets/status_badge.dart), which is used on
/// the booking list card and always shows an icon with fixed, non-responsive
/// sizing — the two have different visual specs and are not interchangeable.
class BookingStatusPill extends StatelessWidget {
  const BookingStatusPill({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Container(
      constraints: BoxConstraints(
        maxWidth: m.badgeMaxWidth,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: m.badgeHPad,
        vertical: m.badgeVPad,
      ),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius:
            BorderRadius.circular(m.badgeRadius),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.brand,
          fontFamily: 'Inter',
          fontSize: m.badgeFontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
