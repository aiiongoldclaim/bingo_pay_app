import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/bookings_entity.dart';
import 'icon_line.dart';

class ScheduleLine extends StatelessWidget {
  const ScheduleLine({super.key, required this.booking});

  final BookingEntity booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final start = _parseDate(booking.scheduledStartAt);
    final end = _parseDate(booking.scheduledEndAt);

    final date = start != null
        ? DateFormat('EEE, dd MMM yyyy').format(start)
        : AppStrings.datePlaceholder;

    final time = start != null
        ? DateFormat('hh:mm a').format(start)
        : AppStrings.timePlaceholder;
    final endTime = end != null ? DateFormat('hh:mm a').format(end) : null;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2.56.w,
      runSpacing: 0.59.h,
      children: [
        IconLine(icon: Icons.calendar_today_rounded, value: date),
        Container(width: 1, height: 1.42.h, color: colors.border),
        IconLine(
          icon: Icons.schedule_rounded,
          value: endTime != null ? '$time - $endTime' : time,
        ),
      ],
    );
  }

  DateTime? _parseDate(String value) {
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }
}
