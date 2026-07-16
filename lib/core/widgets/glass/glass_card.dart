import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_glass.dart';
import 'glass_border.dart';

/// A frosted Liquid Glass panel: translucent fill, hairline border with a
/// brighter specular top edge, and a soft drop shadow.
///
/// By default the fill is a flat translucent colour, which over the smooth
/// [MeshBackground] is indistinguishable from a real backdrop blur and far
/// cheaper. Set [blur] to true only where arbitrary content scrolls behind
/// the panel (tab bars, sheets, sticky headers).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool blur;
  final Color? tint;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 22,
    this.blur = false,
    this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final borderRadius = BorderRadius.circular(radius);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? glass.fill,
        borderRadius: borderRadius,
        border: GlassBorder(glass),
      ),
      child: child,
    );

    if (blur) {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: content,
        ),
      );
    }

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: glass.shadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: content,
    );
  }
}
