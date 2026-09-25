import 'package:flutter/material.dart';

import '../../../../core/theme/theme_colors.dart';
import 'vault_section.dart';

@immutable
class VaultThemeColors {
  const VaultThemeColors({
    required this.headerGradientTop,
    required this.headerGradientMiddle,
    required this.headerGradientBottom,
    required this.primary,
    required this.secondary,
    required this.selectedTabBackground,
    required this.unselectedTabBackground,
    required this.selectedTabText,
    required this.text,
    required this.secondaryText,
    required this.activeCategory,
    required this.searchIcon,
    required this.cartHeartIcon,
    required this.pageBackground,
    required this.sectionBackground,
    required this.cardBackground,
    required this.border,
    required this.button,
    required this.buttonText,
    required this.statusBarIconBrightness,
    required this.statusBarBrightness,
  });

  final Color headerGradientTop;
  final Color headerGradientMiddle;
  final Color headerGradientBottom;
  final Color primary;
  final Color secondary;
  final Color selectedTabBackground;
  final Color unselectedTabBackground;
  final Color selectedTabText;
  final Color text;
  final Color secondaryText;
  final Color activeCategory;
  final Color searchIcon;
  final Color cartHeartIcon;
  final Color pageBackground;
  final Color sectionBackground;
  final Color cardBackground;
  final Color border;
  final Color button;
  final Color buttonText;
  final Brightness statusBarIconBrightness;
  final Brightness statusBarBrightness;

  Color get tabUnselectedBorder =>
      Color.lerp(headerGradientTop, secondary, 0.5)!.withValues(alpha: 0.45);

  Color get searchBorder => secondary.withValues(alpha: 0.3);

  Gradient get bannerOverlay => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primary.withValues(alpha: 0.0),
      primary.withValues(alpha: 0.32),
    ],
  );

  static const theVaults = VaultThemeColors(
    headerGradientTop: ThemeColors.dashboardTheVaultsHeaderTop,
    headerGradientMiddle: ThemeColors.dashboardTheVaultsHeaderMiddle,
    headerGradientBottom: ThemeColors.dashboardTheVaultsHeaderBottom,
    primary: ThemeColors.dashboardTheVaultsPrimary,
    secondary: ThemeColors.dashboardTheVaultsSecondary,
    selectedTabBackground: ThemeColors.dashboardTheVaultsSelectedTab,
    unselectedTabBackground: ThemeColors.dashboardTheVaultsUnselectedTab,
    selectedTabText: ThemeColors.white,
    text: ThemeColors.dashboardTheVaultsText,
    secondaryText: ThemeColors.dashboardTheVaultsText,
    activeCategory: ThemeColors.dashboardTheVaultsActiveCategory,
    searchIcon: ThemeColors.dashboardTheVaultsSearchIcon,
    cartHeartIcon: ThemeColors.dashboardTheVaultsCartIcon,
    pageBackground: ThemeColors.dashboardTheVaultsPageBackground,
    sectionBackground: ThemeColors.dashboardTheVaultsSectionBackground,
    cardBackground: ThemeColors.dashboardTheVaultsCardBackground,
    border: ThemeColors.dashboardTheVaultsBorder,
    button: ThemeColors.dashboardTheVaultsPrimary,
    buttonText: ThemeColors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static const vaultsLuxe = VaultThemeColors(
    headerGradientTop: ThemeColors.dashboardLuxeHeaderTop,
    headerGradientMiddle: ThemeColors.dashboardLuxeHeaderMiddle,
    headerGradientBottom: ThemeColors.dashboardLuxeHeaderBottom,
    primary: ThemeColors.dashboardLuxePrimary,
    secondary: ThemeColors.dashboardLuxeSecondary,
    selectedTabBackground: ThemeColors.dashboardLuxeSelectedTab,
    unselectedTabBackground: ThemeColors.dashboardLuxeUnselectedTab,
    selectedTabText: ThemeColors.white,
    text: ThemeColors.dashboardLuxeText,
    secondaryText: ThemeColors.dashboardLuxeText,
    activeCategory: ThemeColors.dashboardLuxeActiveCategory,
    searchIcon: ThemeColors.dashboardLuxeSearchIcon,
    cartHeartIcon: ThemeColors.dashboardLuxeCartIcon,
    pageBackground: ThemeColors.dashboardLuxePageBackground,
    sectionBackground: ThemeColors.dashboardLuxeSectionBackground,
    cardBackground: ThemeColors.dashboardLuxeCardBackground,
    border: ThemeColors.dashboardLuxeBorder,
    button: ThemeColors.dashboardLuxePrimary,
    buttonText: ThemeColors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static const ultraLuxe = VaultThemeColors(
    headerGradientTop: ThemeColors.dashboardUltraHeaderTop,
    headerGradientMiddle: ThemeColors.dashboardUltraHeaderMiddle,
    headerGradientBottom: ThemeColors.dashboardUltraHeaderBottom,
    primary: ThemeColors.dashboardUltraPrimary,
    secondary: ThemeColors.dashboardUltraSecondary,
    selectedTabBackground: ThemeColors.dashboardUltraSelectedTab,
    unselectedTabBackground: ThemeColors.dashboardUltraUnselectedTab,
    selectedTabText: ThemeColors.white,
    text: ThemeColors.dashboardUltraText,
    secondaryText: ThemeColors.dashboardUltraSecondaryText,
    activeCategory: ThemeColors.dashboardUltraActiveCategory,
    searchIcon: ThemeColors.dashboardUltraSearchIcon,
    cartHeartIcon: ThemeColors.dashboardUltraCartIcon,
    pageBackground: ThemeColors.dashboardUltraPageBackground,
    sectionBackground: ThemeColors.dashboardUltraSectionBackground,
    cardBackground: ThemeColors.dashboardUltraCardBackground,
    border: ThemeColors.dashboardUltraBorder,
    button: ThemeColors.dashboardUltraSecondary,
    buttonText: ThemeColors.dashboardUltraButtonText,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static VaultThemeColors forSection(VaultSection section) {
    switch (section) {
      case VaultSection.theVaults:
        return theVaults;
      case VaultSection.vaultsLuxe:
        return vaultsLuxe;
      case VaultSection.ultraLuxe:
        return ultraLuxe;
    }
  }
}
