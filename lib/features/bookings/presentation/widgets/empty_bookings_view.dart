import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'booking_filter.dart';

class EmptyBookingsView extends StatelessWidget {
  const EmptyBookingsView({super.key, this.filter});

  final BookingFilter? filter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final isFiltered = filter != null && filter != BookingFilter.all;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: colors.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: colors.brand,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'Nothing here' : 'No bookings yet',
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              isFiltered
                  ? 'No bookings match this filter right now.'
                  : 'Your appointments will appear here once you make a booking.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
