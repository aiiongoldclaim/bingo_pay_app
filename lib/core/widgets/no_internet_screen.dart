import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../theme/theme_colors.dart';

/// Full-screen, undismissable blocker shown app-wide whenever connectivity
/// is lost. There is nothing to retry manually — it clears itself the
/// instant the device reconnects (driven by [ConnectivityService].isConnected
/// in app.dart) — so the only action offered is exiting the app.
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  void _exitApp() {
    if (Platform.isIOS) {
      exit(0);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {

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
                  Icons.wifi_off_rounded,
                  size: 44,
                  color: ThemeColors.red,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.ink,
                ),
              ),
              SizedBox(height: 1.2.h),
              Text(
                "You're offline. Please check your Wi-Fi or mobile data — "
                "we'll get you back in as soon as you're reconnected.",
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
                child: OutlinedButton(
                  onPressed: _exitApp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeColors.red,
                    side: const BorderSide(color: ThemeColors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Exit App',
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
  }
}
