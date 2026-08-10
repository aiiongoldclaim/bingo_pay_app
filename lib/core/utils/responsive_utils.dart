import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isTablet = false;
  static bool isMobile = true;
  static bool isTabletPortrait = false;
  static bool isTabletLandscape = false;

  /// Tablet breakpoint — debug output dekh kar adjust kar sakti ho
  static const double _tabletBreakpoint = 540;

  /// Sizer builder ke andar call hota hai
  static void setDeviceType(BuildContext context) {
    final mq = MediaQuery.of(context);

    isTablet = mq.size.shortestSide >= _tabletBreakpoint;
    isMobile = !isTablet;

    final landscape = mq.size.width > mq.size.height;
    isTabletPortrait = isTablet && !landscape;
    isTabletLandscape = isTablet && landscape;

    // ---- TEMP DEBUG (value confirm hone ke baad hata dena) ----
    debugPrint(
      'shortestSide: ${mq.size.shortestSide} | size: ${mq.size} | mode: $currentMode',
    );
    // -----------------------------------------------------------
  }

  static bool get isPhone => isMobile;
  static bool get isTabletOnly => isTablet;

  static String get currentMode {
    if (isTabletPortrait) return 'Tablet (Portrait)';
    if (isTabletLandscape) return 'Tablet (Landscape)';
    return 'Mobile';
  }
}
