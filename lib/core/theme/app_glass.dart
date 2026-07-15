import 'package:flutter/material.dart';

/// Liquid Glass design tokens. Access via `context.glass`.
///
/// Light = pastel mesh wallpaper under white frosted glass.
/// Dark = midnight background with dim colour glows under dark glass.
class AppGlassColors extends ThemeExtension<AppGlassColors> {
  /// Background gradient behind every screen (top-left → bottom-right).
  final Color meshTop;
  final Color meshMid;
  final Color meshBottom;

  /// Soft colour blobs that drift behind the glass.
  final Color blobBlue;
  final Color blobPink;
  final Color blobGreen;

  /// Frosted panel fill / border / top-edge specular highlight.
  final Color fill;
  final Color border;
  final Color specular;
  final Color shadow;

  const AppGlassColors({
    required this.meshTop,
    required this.meshMid,
    required this.meshBottom,
    required this.blobBlue,
    required this.blobPink,
    required this.blobGreen,
    required this.fill,
    required this.border,
    required this.specular,
    required this.shadow,
  });

  static const light = AppGlassColors(
    meshTop: Color(0xFFEAF1FB),
    meshMid: Color(0xFFF6F2FA),
    meshBottom: Color(0xFFEEF7F1),
    blobBlue: Color(0x807AA2FF),
    blobPink: Color(0x6BFFAAD6),
    blobGreen: Color(0x738CE4B4),
    fill: Color(0x80FFFFFF),
    border: Color(0xA6FFFFFF),
    specular: Color(0xE6FFFFFF),
    shadow: Color(0x1A1F264C),
  );

  static const dark = AppGlassColors(
    meshTop: Color(0xFF0E1220),
    meshMid: Color(0xFF161327),
    meshBottom: Color(0xFF0D1A1C),
    blobBlue: Color(0x594C6EF5),
    blobPink: Color(0x40BE5AFF),
    blobGreen: Color(0x382DD4BF),
    fill: Color(0x801E1E24),
    border: Color(0x24FFFFFF),
    specular: Color(0x1FFFFFFF),
    shadow: Color(0x59000000),
  );

  @override
  AppGlassColors copyWith({
    Color? meshTop,
    Color? meshMid,
    Color? meshBottom,
    Color? blobBlue,
    Color? blobPink,
    Color? blobGreen,
    Color? fill,
    Color? border,
    Color? specular,
    Color? shadow,
  }) {
    return AppGlassColors(
      meshTop: meshTop ?? this.meshTop,
      meshMid: meshMid ?? this.meshMid,
      meshBottom: meshBottom ?? this.meshBottom,
      blobBlue: blobBlue ?? this.blobBlue,
      blobPink: blobPink ?? this.blobPink,
      blobGreen: blobGreen ?? this.blobGreen,
      fill: fill ?? this.fill,
      border: border ?? this.border,
      specular: specular ?? this.specular,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppGlassColors lerp(ThemeExtension<AppGlassColors>? other, double t) {
    if (other is! AppGlassColors) return this;
    return AppGlassColors(
      meshTop: Color.lerp(meshTop, other.meshTop, t)!,
      meshMid: Color.lerp(meshMid, other.meshMid, t)!,
      meshBottom: Color.lerp(meshBottom, other.meshBottom, t)!,
      blobBlue: Color.lerp(blobBlue, other.blobBlue, t)!,
      blobPink: Color.lerp(blobPink, other.blobPink, t)!,
      blobGreen: Color.lerp(blobGreen, other.blobGreen, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      border: Color.lerp(border, other.border, t)!,
      specular: Color.lerp(specular, other.specular, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppGlassColorsX on BuildContext {
  AppGlassColors get glass =>
      Theme.of(this).extension<AppGlassColors>() ?? AppGlassColors.light;
}
