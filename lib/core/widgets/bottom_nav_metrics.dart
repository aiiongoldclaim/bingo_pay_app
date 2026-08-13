import 'package:flutter/widgets.dart';

enum NavDeviceClass { phone, tabletPortrait, tabletLandscape }

class BottomNavMetrics {
  final NavDeviceClass device;

  final double barHeight;
  final double horizontalPadding;
  final double contentMaxWidth;

  final double iconSize;
  final double labelSize;
  final double iconLabelGap;

  final double badgeSize;
  final double badgeFontSize;

  final double topBorderWidth;

  const BottomNavMetrics._({
    required this.device,
    required this.barHeight,
    required this.horizontalPadding,
    required this.contentMaxWidth,
    required this.iconSize,
    required this.labelSize,
    required this.iconLabelGap,
    required this.badgeSize,
    required this.badgeFontSize,
    required this.topBorderWidth,
  });

  bool get isTablet => device != NavDeviceClass.phone;

  static const double _tabletBreakpoint = 540;
  static const double _phoneReferenceWidth = 390;

  factory BottomNavMetrics.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= _tabletBreakpoint;
    final landscape = size.width > size.height;

    if (!isTablet) {
      final s = (size.width / _phoneReferenceWidth).clamp(0.85, 1.15);
      double v(double base, double lo, double hi) =>
          (base * s).clamp(lo, hi).toDouble();

      return BottomNavMetrics._(
        device: NavDeviceClass.phone,
        barHeight: v(58, 54, 64),
        horizontalPadding: v(8, 6, 12),
        contentMaxWidth: double.infinity,
        iconSize: v(24, 22, 27),
        labelSize: v(11, 10, 12),
        iconLabelGap: v(4, 3, 6),
        badgeSize: v(16, 14, 18),
        badgeFontSize: v(9, 8, 10),
        topBorderWidth: 1,
      );
    }

    if (!landscape) {
      return const BottomNavMetrics._(
        device: NavDeviceClass.tabletPortrait,
        barHeight: 70,
        horizontalPadding: 24,
        contentMaxWidth: 720,
        iconSize: 28,
        labelSize: 13,
        iconLabelGap: 6,
        badgeSize: 19,
        badgeFontSize: 11,
        topBorderWidth: 1,
      );
    }

    return const BottomNavMetrics._(
      device: NavDeviceClass.tabletLandscape,
      barHeight: 72,
      horizontalPadding: 32,
      contentMaxWidth: 860,
      iconSize: 28,
      labelSize: 13,
      iconLabelGap: 6,
      badgeSize: 20,
      badgeFontSize: 11,
      topBorderWidth: 1,
    );
  }
}
