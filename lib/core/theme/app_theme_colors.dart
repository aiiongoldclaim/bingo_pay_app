import 'package:flutter/material.dart';

import 'theme_colors.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  // ── Surfaces ─────────────────────────────────────────────
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;

  // ── Text ─────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;

  // ── Brand ────────────────────────────────────────────────
  final Color brand;
  final Color brandSoft;
  final Color onBrand;
  final Color accent;
  final Color onAccent;

  // ── Sections ─────────────────────────────────────────────
  final Color categoryCircleBg;
  final Color servicesBg;
  final Color discount;

  // ── Buttons ──────────────────────────────────────────────
  final LinearGradient buttonPrimaryGradient;
  final LinearGradient buttonSecondaryGradient;
  final Color buttonDisabledFill;

  // ── Gradients ────────────────────────────────────────────
  final LinearGradient heroBanner;
  final LinearGradient benefitsStrip;

  /// Hero gradient ke upar text/icon
  final Color onHeroBanner;

  /// Hero gradient ke upar halka fill (badge, close button)
  final Color heroBannerOverlay;

  // ── Nav ──────────────────────────────────────────────────
  final Color navBackground;
  final Color navSelected;
  final Color navUnselected;

  // ── Status ───────────────────────────────────────────────
  final Color statusSuccess;
  final Color statusWarning;
  final Color statusInfo;
  final Color statusSuccessSoft;
  final Color statusWarningSoft;
  final Color error;
  final Color onError;

  // ── Overlays ─────────────────────────────────────────────
  /// Dialog / bottom sheet barrier
  final Color scrim;
  final Color dialogShadow;

  // ── Onboarding ───────────────────────────────────────────
  final LinearGradient onboardingBackground;
  final Color onboardingTitle;
  final Color onboardingBody;
  final Color onboardingAccent;
  final Color onboardingDotIdle;
  final Color onboardingBorder;
  final LinearGradient onboardingNextGradient;
  final Color onboardingNextText;

  final bool isDark;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.brand,
    required this.brandSoft,
    required this.onBrand,
    required this.accent,
    required this.onAccent,
    required this.categoryCircleBg,
    required this.servicesBg,
    required this.discount,
    required this.buttonPrimaryGradient,
    required this.buttonSecondaryGradient,
    required this.buttonDisabledFill,
    required this.heroBanner,
    required this.benefitsStrip,
    required this.onHeroBanner,
    required this.heroBannerOverlay,
    required this.navBackground,
    required this.navSelected,
    required this.navUnselected,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusInfo,
    required this.statusSuccessSoft,
    required this.statusWarningSoft,
    required this.error,
    required this.onError,
    required this.scrim,
    required this.dialogShadow,
    required this.onboardingBackground,
    required this.onboardingTitle,
    required this.onboardingBody,
    required this.onboardingAccent,
    required this.onboardingDotIdle,
    required this.onboardingBorder,
    required this.onboardingNextGradient,
    required this.onboardingNextText,
    required this.isDark,
  });

  // ── LIGHT ────────────────────────────────────────────────
  static const lightColors = AppThemeColors(
    background: ThemeColors.background,
    surface: ThemeColors.white,
    surfaceAlt: ThemeColors.veryLightLavender,
    border: ThemeColors.border,

    textPrimary: ThemeColors.textPrimary,
    textSecondary: ThemeColors.textSecondary1,
    textMuted: ThemeColors.textMuted,
    textDisabled: ThemeColors.inkDim,

    brand: ThemeColors.primaryPurple,
    brandSoft: ThemeColors.lightLavender,
    onBrand: ThemeColors.white,
    accent: ThemeColors.lavender,
    onAccent: ThemeColors.white,

    categoryCircleBg: ThemeColors.veryLightLavender,
    servicesBg: ThemeColors.serviceBackground,
    discount: ThemeColors.primaryPurple,

    buttonPrimaryGradient: ThemeColors.primaryButtonGradient,
    buttonSecondaryGradient: ThemeColors.secondaryButtonGradient,
    buttonDisabledFill: ThemeColors.line,

    heroBanner: ThemeColors.heroBannerLight,
    benefitsStrip: ThemeColors.benefitsStripLight,
    onHeroBanner: ThemeColors.white,
    heroBannerOverlay: Color(0x29FFFFFF),

    navBackground: ThemeColors.white,
    navSelected: ThemeColors.primaryPurple,
    navUnselected: ThemeColors.textSecondary1,

    statusSuccess: ThemeColors.green,
    statusWarning: ThemeColors.amber,
    statusInfo: ThemeColors.primaryPurple,
    statusSuccessSoft: ThemeColors.greenSoft,
    statusWarningSoft: Color(0xFFFFF3E5),
    error: ThemeColors.red,
    onError: ThemeColors.white,

    scrim: Color(0xA6000000),
    dialogShadow: Color(0x334C1E76),

    onboardingBackground: LinearGradient(
      colors: [ThemeColors.surface, ThemeColors.background],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    onboardingTitle: ThemeColors.textDark,
    onboardingBody: ThemeColors.inkMid,
    onboardingAccent: ThemeColors.deepPurple,
    onboardingDotIdle: Color(0x290E1525),
    onboardingBorder: ThemeColors.line,
    onboardingNextGradient: ThemeColors.bottomSection,
    onboardingNextText: ThemeColors.white,

    isDark: false,
  );

  // ── DARK ─────────────────────────────────────────────────
  static const darkColors = AppThemeColors(
    background: ThemeColors.darkBackground,
    surface: ThemeColors.darkSurface,
    surfaceAlt: ThemeColors.darkSurfaceAlt,
    border: ThemeColors.darkBorder,

    textPrimary: ThemeColors.darkTextPrimary,
    textSecondary: ThemeColors.darkTextSecondary,
    textMuted: ThemeColors.darkTextMuted,
    textDisabled: Color(0xFF52525B),

    brand: ThemeColors.darkPurple,
    brandSoft: ThemeColors.darkPurpleSoft,
    onBrand: ThemeColors.white,
    accent: Color(0xFFB794F6),
    onAccent: Color(0xFF1E1330),

    categoryCircleBg: ThemeColors.darkSurfaceAlt,
    servicesBg: ThemeColors.darkSurface,
    discount: ThemeColors.darkPurple,

    buttonPrimaryGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF7C3AED), Color(0xFF9F67FF)],
    ),
    buttonSecondaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2A1B45), Color(0xFF1E1330)],
    ),
    buttonDisabledFill: Color(0xFF232326),

    heroBanner: ThemeColors.heroBannerDark,
    benefitsStrip: ThemeColors.benefitsStripDark,
    onHeroBanner: ThemeColors.white,
    heroBannerOverlay: Color(0x1AFFFFFF),

    navBackground: ThemeColors.darkBackground,
    navSelected: ThemeColors.darkPurple,
    navUnselected: ThemeColors.darkTextSecondary,

    statusSuccess: Color(0xFF34D399),
    statusWarning: Color(0xFFFBBF24),
    statusInfo: ThemeColors.darkPurple,
    statusSuccessSoft: Color(0xFF13291F),
    statusWarningSoft: Color(0xFF2B2113),
    error: Color(0xFFF87171),
    onError: Color(0xFF2A0E0A),

    scrim: Color(0xA6000000),
    dialogShadow: Color(0x8C000000),

    onboardingBackground: ThemeColors.onboardingDarkBg,
    onboardingTitle: ThemeColors.white,
    onboardingBody: ThemeColors.inkDim,
    onboardingAccent: ThemeColors.gold,
    onboardingDotIdle: Color(0x38FFFFFF),
    onboardingBorder: Color(0x24FFFFFF),
    onboardingNextGradient: ThemeColors.bottomSection,
    onboardingNextText: ThemeColors.white,

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
    Color? textDisabled,
    Color? brand,
    Color? brandSoft,
    Color? onBrand,
    Color? accent,
    Color? onAccent,
    Color? categoryCircleBg,
    Color? servicesBg,
    Color? discount,
    LinearGradient? buttonPrimaryGradient,
    LinearGradient? buttonSecondaryGradient,
    Color? buttonDisabledFill,
    LinearGradient? heroBanner,
    LinearGradient? benefitsStrip,
    Color? onHeroBanner,
    Color? heroBannerOverlay,
    Color? navBackground,
    Color? navSelected,
    Color? navUnselected,
    Color? statusSuccess,
    Color? statusWarning,
    Color? statusInfo,
    Color? statusSuccessSoft,
    Color? statusWarningSoft,
    Color? error,
    Color? onError,
    Color? scrim,
    Color? dialogShadow,
    LinearGradient? onboardingBackground,
    Color? onboardingTitle,
    Color? onboardingBody,
    Color? onboardingAccent,
    Color? onboardingDotIdle,
    Color? onboardingBorder,
    LinearGradient? onboardingNextGradient,
    Color? onboardingNextText,
    bool? isDark,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      brand: brand ?? this.brand,
      brandSoft: brandSoft ?? this.brandSoft,
      onBrand: onBrand ?? this.onBrand,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      categoryCircleBg: categoryCircleBg ?? this.categoryCircleBg,
      servicesBg: servicesBg ?? this.servicesBg,
      discount: discount ?? this.discount,
      buttonPrimaryGradient:
      buttonPrimaryGradient ?? this.buttonPrimaryGradient,
      buttonSecondaryGradient:
      buttonSecondaryGradient ?? this.buttonSecondaryGradient,
      buttonDisabledFill: buttonDisabledFill ?? this.buttonDisabledFill,
      heroBanner: heroBanner ?? this.heroBanner,
      benefitsStrip: benefitsStrip ?? this.benefitsStrip,
      onHeroBanner: onHeroBanner ?? this.onHeroBanner,
      heroBannerOverlay: heroBannerOverlay ?? this.heroBannerOverlay,
      navBackground: navBackground ?? this.navBackground,
      navSelected: navSelected ?? this.navSelected,
      navUnselected: navUnselected ?? this.navUnselected,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusWarning: statusWarning ?? this.statusWarning,
      statusInfo: statusInfo ?? this.statusInfo,
      statusSuccessSoft: statusSuccessSoft ?? this.statusSuccessSoft,
      statusWarningSoft: statusWarningSoft ?? this.statusWarningSoft,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      scrim: scrim ?? this.scrim,
      dialogShadow: dialogShadow ?? this.dialogShadow,
      onboardingBackground: onboardingBackground ?? this.onboardingBackground,
      onboardingTitle: onboardingTitle ?? this.onboardingTitle,
      onboardingBody: onboardingBody ?? this.onboardingBody,
      onboardingAccent: onboardingAccent ?? this.onboardingAccent,
      onboardingDotIdle: onboardingDotIdle ?? this.onboardingDotIdle,
      onboardingBorder: onboardingBorder ?? this.onboardingBorder,
      onboardingNextGradient:
      onboardingNextGradient ?? this.onboardingNextGradient,
      onboardingNextText: onboardingNextText ?? this.onboardingNextText,
      isDark: isDark ?? this.isDark,
    );
  }

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
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandSoft: Color.lerp(brandSoft, other.brandSoft, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      categoryCircleBg:
      Color.lerp(categoryCircleBg, other.categoryCircleBg, t)!,
      servicesBg: Color.lerp(servicesBg, other.servicesBg, t)!,
      discount: Color.lerp(discount, other.discount, t)!,
      buttonPrimaryGradient: LinearGradient.lerp(
        buttonPrimaryGradient,
        other.buttonPrimaryGradient,
        t,
      )!,
      buttonSecondaryGradient: LinearGradient.lerp(
        buttonSecondaryGradient,
        other.buttonSecondaryGradient,
        t,
      )!,
      buttonDisabledFill:
      Color.lerp(buttonDisabledFill, other.buttonDisabledFill, t)!,
      heroBanner: LinearGradient.lerp(heroBanner, other.heroBanner, t)!,
      benefitsStrip:
      LinearGradient.lerp(benefitsStrip, other.benefitsStrip, t)!,
      onHeroBanner: Color.lerp(onHeroBanner, other.onHeroBanner, t)!,
      heroBannerOverlay:
      Color.lerp(heroBannerOverlay, other.heroBannerOverlay, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
      navUnselected: Color.lerp(navUnselected, other.navUnselected, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      statusSuccessSoft:
      Color.lerp(statusSuccessSoft, other.statusSuccessSoft, t)!,
      statusWarningSoft:
      Color.lerp(statusWarningSoft, other.statusWarningSoft, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      dialogShadow: Color.lerp(dialogShadow, other.dialogShadow, t)!,
      onboardingBackground: LinearGradient.lerp(
        onboardingBackground,
        other.onboardingBackground,
        t,
      )!,
      onboardingTitle: Color.lerp(onboardingTitle, other.onboardingTitle, t)!,
      onboardingBody: Color.lerp(onboardingBody, other.onboardingBody, t)!,
      onboardingAccent:
      Color.lerp(onboardingAccent, other.onboardingAccent, t)!,
      onboardingDotIdle:
      Color.lerp(onboardingDotIdle, other.onboardingDotIdle, t)!,
      onboardingBorder:
      Color.lerp(onboardingBorder, other.onboardingBorder, t)!,
      onboardingNextGradient: LinearGradient.lerp(
        onboardingNextGradient,
        other.onboardingNextGradient,
        t,
      )!,
      onboardingNextText:
      Color.lerp(onboardingNextText, other.onboardingNextText, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AppThemeColorsX on BuildContext {
  AppThemeColors get colors => AppThemeColors.of(this);

  @Deprecated('Use context.colors instead')
  AppThemeColors get c => AppThemeColors.of(this);
}