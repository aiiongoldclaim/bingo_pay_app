import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'booking_details_metrics.dart';

class BookingDetailsErrorView extends StatelessWidget {
  const BookingDetailsErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(m.cardPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: m.errorIconBox,
              height: m.errorIconBox,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: c.brand,
                size: m.errorIconSize,
              ),
            ),
            SizedBox(height: m.errorGap1),
            Text(
              AppStrings.unableToLoadBooking,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontSize: m.errorTitleSize,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: m.errorGap2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.errorBodySize,
                height: 1.4,
              ),
            ),
            SizedBox(height: m.errorGap3),
            SizedBox(
              height: m.errorBtnHeight,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.brand,
                  foregroundColor: c.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(m.errorBtnRadius),
                  ),
                ),
                child: const Text(
                  AppStrings.tryAgainSentenceCase,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
