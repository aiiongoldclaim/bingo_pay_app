import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Chart colors for the analytics screen.
///
/// The order-status palettes were validated (per mode, against the card
/// surface) for lightness band, chroma floor, CVD separation and contrast —
/// don't swap in raw theme tints here without re-validating.
class AnalyticsChartStyle {
  AnalyticsChartStyle._();

  static const _statusLight = {
    'PENDING': Color(0xFFB36B00),
    'CONFIRMED': Color(0xFF1A5DAB),
    'DELIVERED': Color(0xFF4C7A2D),
    'CANCELLED': Color(0xFFEA4335),
  };

  static const _statusDark = {
    'PENDING': Color(0xFFBA8405),
    'CONFIRMED': Color(0xFF5B93E8),
    'DELIVERED': Color(0xFF4FA96A),
    'CANCELLED': Color(0xFFE2695C),
  };

  /// Fixed display order so a status keeps its slot no matter what the
  /// payload contains; unknown statuses go last in muted gray.
  static const statusOrder = ['PENDING', 'CONFIRMED', 'DELIVERED', 'CANCELLED'];

  static Color statusColor(BuildContext context, String status) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final map = dark ? _statusDark : _statusLight;
    return map[status.toUpperCase()] ??
        (dark ? const Color(0xFF80868B) : const Color(0xFF9E9E9E));
  }

  /// Single-series line color — brand navy is too dark on the dark surface,
  /// so dark mode uses the info-blue step instead.
  static Color lineColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF8AB4F8)
        : AppColors.primary;
  }

  /// Hairline gridline, one step off the surface.
  static Color gridColor(BuildContext context) =>
      context.colors.border.withValues(alpha: 0.6);
}
