import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'booking_details_metrics.dart';

class BookingDetailsHeader extends StatelessWidget {
  const BookingDetailsHeader({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = BookingDetailsMetrics.of(context);

    return SizedBox(
      height: m.headerHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(m.headerPadLeft, 0, m.headerPadRight, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              splashRadius: m.headerBackSplash,
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: m.headerBackIconSize,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(width: m.headerTitleGapW),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.bookingDetailsTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontFamily: 'Inter',
                      fontSize: m.headerTitleSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: m.headerTitleGapH),
                  Text(
                    AppStrings.reviewYourAppointment,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.headerSubtitleSize,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
