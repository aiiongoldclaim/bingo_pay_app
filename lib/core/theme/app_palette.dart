// core/theme/app_palette.dart
import 'package:flutter/material.dart';
import 'theme_colors.dart';

enum AppPaletteType { purple, blue, green, orange }

class AppPalette {
  final AppPaletteType type;
  final Color primary;
  final Color accent;

  const AppPalette({
    required this.type,
    required this.primary,
    required this.accent,
  });

  static const purple = AppPalette(
    type: AppPaletteType.purple,
    primary: ThemeColors.primaryPurple,
    accent: ThemeColors.accent,
  );

  static const blue = AppPalette(
    type: AppPaletteType.blue,
    primary: ThemeColors.blue,
    accent: ThemeColors.accent,
  );

  static const green = AppPalette(
    type: AppPaletteType.green,
    primary: ThemeColors.green,
    accent: ThemeColors.accent,
  );

  static final orange = AppPalette(
    type: AppPaletteType.orange,
    primary: ThemeColors.orange,
    accent: ThemeColors.accent,
  );

  static AppPalette fromType(AppPaletteType t) => switch (t) {
    AppPaletteType.purple => purple,
    AppPaletteType.blue => blue,
    AppPaletteType.green => green,
    AppPaletteType.orange => orange,
  };
}
