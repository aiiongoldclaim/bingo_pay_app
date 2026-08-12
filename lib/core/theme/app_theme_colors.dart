import 'package:flutter/material.dart';
import 'theme_colors.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color brand;
  final Color brandSoft;
  final Color categoryCircleBg;
  final Color servicesBg;
  final Color discount;
  final LinearGradient heroBanner;
  final LinearGradient benefitsStrip;
  final bool isDark;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.brand,
    required this.brandSoft,
    required this.categoryCircleBg,
    required this.servicesBg,
    required this.discount,
    required this.heroBanner,
    required this.benefitsStrip,
    required this.isDark,
  });

  static const lightColors = AppThemeColors(
    background: ThemeColors.background,
    surface: ThemeColors.white,
    surfaceAlt: ThemeColors.veryLightLavender,
    border: ThemeColors.border,
    textPrimary: ThemeColors.textPrimary,
    textSecondary: ThemeColors.textSecondary1,
    textMuted: ThemeColors.textMuted,
    brand: ThemeColors.primaryPurple,
    brandSoft: ThemeColors.lightLavender,
    categoryCircleBg: ThemeColors.veryLightLavender,
    servicesBg: ThemeColors.serviceBackground,
    discount: ThemeColors.primaryPurple,
    heroBanner: ThemeColors.heroBannerLight,
    benefitsStrip: ThemeColors.benefitsStripLight,
    isDark: false,
  );

  static const darkColors = AppThemeColors(
    background: ThemeColors.darkBackground,
    surface: ThemeColors.darkSurface,
    surfaceAlt: ThemeColors.darkSurfaceAlt,
    border: ThemeColors.darkBorder,
    textPrimary: ThemeColors.darkTextPrimary,
    textSecondary: ThemeColors.darkTextSecondary,
    textMuted: ThemeColors.darkTextMuted,
    brand: ThemeColors.darkPurple,
    brandSoft: ThemeColors.darkPurpleSoft,
    categoryCircleBg: ThemeColors.darkSurfaceAlt,
    servicesBg: ThemeColors.darkSurface,
    discount: ThemeColors.darkPurple,
    heroBanner: ThemeColors.heroBannerDark,
    benefitsStrip: ThemeColors.benefitsStripDark,
    isDark: true,
  );

  static AppThemeColors of(BuildContext context) =>
      Theme.of(context).extension<AppThemeColors>() ?? lightColors;

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? brand,
    Color? brandSoft,
    Color? categoryCircleBg,
    Color? servicesBg,
    Color? discount,
    LinearGradient? heroBanner,
    LinearGradient? benefitsStrip,
    bool? isDark,
  }) => AppThemeColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    border: border ?? this.border,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted: textMuted ?? this.textMuted,
    brand: brand ?? this.brand,
    brandSoft: brandSoft ?? this.brandSoft,
    categoryCircleBg: categoryCircleBg ?? this.categoryCircleBg,
    servicesBg: servicesBg ?? this.servicesBg,
    discount: discount ?? this.discount,
    heroBanner: heroBanner ?? this.heroBanner,
    benefitsStrip: benefitsStrip ?? this.benefitsStrip,
    isDark: isDark ?? this.isDark,
  );

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandSoft: Color.lerp(brandSoft, other.brandSoft, t)!,
      categoryCircleBg: Color.lerp(
        categoryCircleBg,
        other.categoryCircleBg,
        t,
      )!,
      servicesBg: Color.lerp(servicesBg, other.servicesBg, t)!,
      discount: Color.lerp(discount, other.discount, t)!,
      heroBanner: LinearGradient.lerp(heroBanner, other.heroBanner, t)!,
      benefitsStrip: LinearGradient.lerp(
        benefitsStrip,
        other.benefitsStrip,
        t,
      )!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AppThemeColorsX on BuildContext {
  AppThemeColors get c => AppThemeColors.of(this);
}
