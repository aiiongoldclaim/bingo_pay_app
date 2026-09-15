import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';

class BookingsHeader extends StatelessWidget {
  const BookingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 6.87.h,
      child: Padding(
        padding: EdgeInsets.fromLTRB(1.03.w, 0, 4.1.w, 0),
        child: Row(
          children: [
            if (context.canPop())
              IconButton(
                onPressed: () => context.pop(),
                splashRadius: 20.sp,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: colors.textPrimary,
                ),
              )
            else
              SizedBox(width: 3.08.w),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.myBookingsTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontFamily: 'Inter',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 0.24.h),
                  Text(
                    AppStrings.myBookingsSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
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
