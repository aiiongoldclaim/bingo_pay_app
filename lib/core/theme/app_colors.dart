import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF1B2A6B);
  static const Color primaryDark = Color(0xFF121C4A);
  static const Color secondary = Color(0xFF34A853);

  // Neutrals
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textPrimaryDark = Color(0xFFE8EAED);
  static const Color textSecondaryDark = Color(0xFF9AA0A6);

  // Semantic
  static const Color success = Color(0xFF34A853);
  static const Color error = Color(0xFFEA4335);
  static const Color warning = Color(0xFFFBBC04);
  static const Color info = Color(0xFF4285F4);

  // Semantic tints (icon-chip / pill backgrounds)
  static const Color successTint = Color(0xFFE3F3E6);
  static const Color warningTint = Color(0xFFFCEFD9);
  static const Color infoTint = Color(0xFFE3EDFC);
  static const Color errorTint = Color(0xFFFBE5E3);

  // Extra accent (used for "orders" stat card)
  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color accentPurpleTint = Color(0xFFEDE7FB);

  // Dividers
  static const Color divider = Color(0xFFE0E0E0);
}

/// Brightness-dependent semantic colors. Access via `context.colors`.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color background;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color inputFill;
  final Color shadow;
  final Color successFg;
  final Color successTint;
  final Color warningFg;
  final Color warningTint;
  final Color infoFg;
  final Color infoTint;
  final Color errorFg;
  final Color errorTint;
  final Color purpleFg;
  final Color purpleTint;

  const AppSemanticColors({
    required this.background,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.inputFill,
    required this.shadow,
    required this.successFg,
    required this.successTint,
    required this.warningFg,
    required this.warningTint,
    required this.infoFg,
    required this.infoTint,
    required this.errorFg,
    required this.errorTint,
    required this.purpleFg,
    required this.purpleTint,
  });

  static const light = AppSemanticColors(
    background: Color(0xFFF4F5F7),
    card: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF202124),
    textSecondary: Color(0xFF5F6368),
    textMuted: Color(0xFF9E9E9E),
    border: Color(0xFFE0E0E0),
    inputFill: Color(0xFFFFFFFF),
    shadow: Color(0x0A000000),
    successFg: Color(0xFF4C7A2D),
    successTint: Color(0xFFE3F3E6),
    warningFg: Color(0xFFB36B00),
    warningTint: Color(0xFFFCEFD9),
    infoFg: Color(0xFF1A5DAB),
    infoTint: Color(0xFFE3EDFC),
    errorFg: Color(0xFFEA4335),
    errorTint: Color(0xFFFBE5E3),
    purpleFg: Color(0xFF7C4DFF),
    purpleTint: Color(0xFFEDE7FB),
  );

  static const dark = AppSemanticColors(
    background: Color(0xFF121212),
    card: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFE8EAED),
    textSecondary: Color(0xFF9AA0A6),
    textMuted: Color(0xFF80868B),
    border: Color(0xFF3C4043),
    inputFill: Color(0xFF2A2B2E),
    shadow: Color(0x00000000),
    successFg: Color(0xFF81C995),
    successTint: Color(0x2634A853),
    warningFg: Color(0xFFFDD663),
    warningTint: Color(0x26FBBC04),
    infoFg: Color(0xFF8AB4F8),
    infoTint: Color(0x264285F4),
    errorFg: Color(0xFFF28B82),
    errorTint: Color(0x26EA4335),
    purpleFg: Color(0xFFB39DDB),
    purpleTint: Color(0x267C4DFF),
  );

  @override
  AppSemanticColors copyWith({
    Color? background,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? inputFill,
    Color? shadow,
    Color? successFg,
    Color? successTint,
    Color? warningFg,
    Color? warningTint,
    Color? infoFg,
    Color? infoTint,
    Color? errorFg,
    Color? errorTint,
    Color? purpleFg,
    Color? purpleTint,
  }) {
    return AppSemanticColors(
      background: background ?? this.background,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      inputFill: inputFill ?? this.inputFill,
      shadow: shadow ?? this.shadow,
      successFg: successFg ?? this.successFg,
      successTint: successTint ?? this.successTint,
      warningFg: warningFg ?? this.warningFg,
      warningTint: warningTint ?? this.warningTint,
      infoFg: infoFg ?? this.infoFg,
      infoTint: infoTint ?? this.infoTint,
      errorFg: errorFg ?? this.errorFg,
      errorTint: errorTint ?? this.errorTint,
      purpleFg: purpleFg ?? this.purpleFg,
      purpleTint: purpleTint ?? this.purpleTint,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      successFg: Color.lerp(successFg, other.successFg, t)!,
      successTint: Color.lerp(successTint, other.successTint, t)!,
      warningFg: Color.lerp(warningFg, other.warningFg, t)!,
      warningTint: Color.lerp(warningTint, other.warningTint, t)!,
      infoFg: Color.lerp(infoFg, other.infoFg, t)!,
      infoTint: Color.lerp(infoTint, other.infoTint, t)!,
      errorFg: Color.lerp(errorFg, other.errorFg, t)!,
      errorTint: Color.lerp(errorTint, other.errorTint, t)!,
      purpleFg: Color.lerp(purpleFg, other.purpleFg, t)!,
      purpleTint: Color.lerp(purpleTint, other.purpleTint, t)!,
    );
  }
}

extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get colors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
