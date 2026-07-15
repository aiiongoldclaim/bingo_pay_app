import 'package:flutter/widgets.dart';

class AppResponsive {
  final double width;
  final double height;

  const AppResponsive({required this.width, required this.height});

  factory AppResponsive.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return AppResponsive(width: size.width, height: size.height);
  }

  /// Percentage of screen width. e.g. w(4) = 4% of screen width.
  double w(double percent) => width * percent / 100;

  /// Percentage of screen height. e.g. h(2) = 2% of screen height.
  double h(double percent) => height * percent / 100;

  /// Font size scaled to screen width. Base design width: 375px.
  double sp(double size) => size * (width / 375).clamp(0.85, 1.35);
}

extension ResponsiveContext on BuildContext {
  AppResponsive get r => AppResponsive.of(this);
}
