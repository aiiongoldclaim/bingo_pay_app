import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'booking_details_metrics.dart';

class BookingSectionTitle extends StatelessWidget {
  const BookingSectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: m.sectionIconSize,
          color: colors.brand,
        ),
        SizedBox(width: m.sectionIconGapW),
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontFamily: 'Inter',
            fontSize: m.sectionTitleTextSize,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
