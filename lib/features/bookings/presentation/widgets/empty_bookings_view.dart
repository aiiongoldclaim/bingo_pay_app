import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_strings.dart';
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
        padding: EdgeInsets.all(7.69.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 21.03.w,
              height: 21.03.w,
              decoration: BoxDecoration(
                color: colors.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: colors.brand,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 2.37.h),
            Text(
              isFiltered
                  ? AppStrings.nothingHereTitle
                  : AppStrings.noBookingsYetTitle,
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 0.83.h),
            Text(
              isFiltered
                  ? AppStrings.noBookingsMatchFilter
                  : AppStrings.noBookingsBody,
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
