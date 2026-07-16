import 'package:flutter/material.dart';

import '../../theme/app_glass.dart';

/// Hairline border for frosted glass panels: a rounded-rect stroke fading
/// from the brighter [AppGlassColors.specular] at the top edge into
/// [AppGlassColors.border] below.
///
/// A plain [Border] with a different top-side colour cannot be combined with
/// a borderRadius (Flutter asserts on paint), so the specular highlight is
/// painted as a vertical gradient stroke instead.
class GlassBorder extends BoxBorder {
  final Color specularColor;
  final Color borderColor;
  final double width;

  GlassBorder(AppGlassColors glass, {this.width = 1})
      : specularColor = glass.specular,
        borderColor = glass.border;

  const GlassBorder.colors({
    required this.specularColor,
    required this.borderColor,
    this.width = 1,
  });

  @override
  BorderSide get top => BorderSide(color: specularColor, width: width);

  @override
  BorderSide get bottom => BorderSide(color: borderColor, width: width);

  @override
  bool get isUniform => true;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  ShapeBorder scale(double t) => GlassBorder.colors(
        specularColor: specularColor,
        borderColor: borderColor,
        width: width * t,
      );

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadiusGeometry? borderRadius,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [specularColor, borderColor],
        stops: const [0.0, 0.45],
      ).createShader(rect);

    final inner = rect.deflate(width / 2);
    if (shape == BoxShape.circle) {
      canvas.drawOval(inner, paint);
    } else if (borderRadius != null && borderRadius != BorderRadius.zero) {
      canvas.drawRRect(
        borderRadius.resolve(textDirection).toRRect(rect).deflate(width / 2),
        paint,
      );
    } else {
      canvas.drawRect(inner, paint);
    }
  }
}
