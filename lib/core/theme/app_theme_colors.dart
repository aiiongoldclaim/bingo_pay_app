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

  final Color navBackground;
  final Color navSelected;
  final Color navUnselected;

  final Color statusSuccess;
  final Color statusWarning;
  final Color statusInfo;
  final Color statusSuccessSoft;
  final Color statusWarningSoft;

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
    required this.navBackground,
    required this.navSelected,
    required this.navUnselected,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusInfo,
    required this.statusSuccessSoft,
    required this.statusWarningSoft,
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
    navBackground: ThemeColors.white,
    navSelected: ThemeColors.primaryPurple,
    navUnselected: ThemeColors.textSecondary1,
    statusSuccess: ThemeColors.green,
    statusWarning: ThemeColors.orange,
    statusInfo: ThemeColors.primaryPurple,
    statusSuccessSoft: ThemeColors.greenSoft,
    statusWarningSoft: Color(0xFFFFF3E5),
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
    navBackground: ThemeColors.darkBackground,
    navSelected: ThemeColors.darkPurple,
    navUnselected: ThemeColors.darkTextSecondary,
    statusSuccess: Color(0xFF34D399),
    statusWarning: Color(0xFFFBBF24),
    statusInfo: ThemeColors.darkPurple,
    statusSuccessSoft: Color(0xFF13291F),
    statusWarningSoft: Color(0xFF2B2113),
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
    Color? navBackground,
    Color? navSelected,
    Color? navUnselected,
    Color? statusSuccess, // ADDED
    Color? statusWarning, // ADDED
    Color? statusInfo, // ADDED
    Color? statusSuccessSoft, // ADDED
    Color? statusWarningSoft, // ADDED
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
    navBackground: navBackground ?? this.navBackground,
    navSelected: navSelected ?? this.navSelected,
    navUnselected: navUnselected ?? this.navUnselected,
    // FIXED: pehle yahan `null` pass ho raha tha
    statusSuccess: statusSuccess ?? this.statusSuccess,
    statusWarning: statusWarning ?? this.statusWarning,
    statusInfo: statusInfo ?? this.statusInfo,
    statusSuccessSoft: statusSuccessSoft ?? this.statusSuccessSoft,
    statusWarningSoft: statusWarningSoft ?? this.statusWarningSoft,
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
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
      navUnselected: Color.lerp(navUnselected, other.navUnselected, t)!,
      // ADDED: ye paanch missing the
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      statusSuccessSoft: Color.lerp(
        statusSuccessSoft,
        other.statusSuccessSoft,
        t,
      )!,
      statusWarningSoft: Color.lerp(
        statusWarningSoft,
        other.statusWarningSoft,
        t,
      )!,
    );
  }
}

extension AppThemeColorsX on BuildContext {
  AppThemeColors get c => AppThemeColors.of(this);
}
