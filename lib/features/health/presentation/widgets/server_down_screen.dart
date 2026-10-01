import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/theme_colors.dart';
import '../cubit/health_cubit.dart';
import '../cubit/health_state.dart';

/// Full-screen blocker shown app-wide when the startup health check says
/// the backend can't serve requests. Mirrors [NoInternetScreen]'s look.
class ServerDownScreen extends StatelessWidget {
  const ServerDownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthCubit, HealthState>(
      builder: (context, state) {
        final isRetrying = state is HealthChecking;
        final message = state is HealthDown
            ? state.message
            : "We couldn't reach our servers. Please try again in a few minutes.";

        return Material(
          color: ThemeColors.white,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: ThemeColors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      size: 44,
                      color: ThemeColors.red,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Service Unavailable',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.ink,
                    ),
                  ),
                  SizedBox(height: 1.2.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      color: ThemeColors.inkMid,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: double.infinity,
                    height: 6.2.h,
                    child: ElevatedButton(
                      onPressed: isRetrying
                          ? null
                          : () => context.read<HealthCubit>().checkHealth(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primaryPurple,
                        foregroundColor: ThemeColors.white,
                        disabledBackgroundColor:
                            ThemeColors.primaryPurple.withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isRetrying
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: ThemeColors.white,
                              ),
                            )
                          : Text(
                              'Try Again',
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
