import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isTablet = false;
  static bool isMobile = true;
  static bool isTabletPortrait = false;
  static bool isTabletLandscape = false;

  /// Tablet breakpoint, in logical pixels of the shortest side.
  static const double _tabletBreakpoint = 540;

  /// Called from inside the root Sizer builder.
  static void setDeviceType(BuildContext context) {
    final mq = MediaQuery.of(context);

    isTablet = mq.size.shortestSide >= _tabletBreakpoint;
    isMobile = !isTablet;

    final landscape = mq.size.width > mq.size.height;
    isTabletPortrait = isTablet && !landscape;
    isTabletLandscape = isTablet && landscape;
  }

  static bool get isPhone => isMobile;
  static bool get isTabletOnly => isTablet;

  static String get currentMode {
    if (isTabletPortrait) return 'Tablet (Portrait)';
    if (isTabletLandscape) return 'Tablet (Landscape)';
    return 'Mobile';
  }
}
