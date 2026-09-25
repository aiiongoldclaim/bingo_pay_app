import 'dart:ui';

import 'package:flutter/cupertino.dart';

class ThemeColors {


  static const primaryPurple = Color(0xFF4C1E76);
  static const deepPurple = Color(0xFF3F185F);
  static const mediumPurple = Color(0xFF6B3A91);

  // Lavender
  static const lavender = Color(0xFFA98BC8);
  static const lightLavender = Color(0xFFE5DCF1);
  static const veryLightLavender = Color(0xFFF5F1F8);
  static const purpleTint = Color(0xFFF0EAF6);

  // Background
  static const background = Color(0xFFFFFFFF);

  // Text
  static const textPrimary = Color(0xFF17151A);
  static const textSecondary1 = Color(0xFF6B6870);
  static const textMuted = Color(0xFF9B989F);

  // Border
  static const border = Color(0xFFE4E0E8);

  // Service section
  static const serviceBackground = Color(0xFFFDF4ED);

  // Success / Discount
  static const discount = Color(0xFF4C1E76);

  // White
  static const white = Color(0xFFFFFFFF);

  static const Color blue = Color(0xFF1B4AE4);
  static const Color blueDeep = Color(0xFF0E2A78);
  static const Color bluePress = Color(0xFF1740BF);
  static const Color blueSoft = Color(0xFFE7EDFD);

  //orange
  static const Color orange = Color(0xffFF9400);

  // =========================
  // GOLD PALETTE
  // =========================

  static const Color accent = Color(0xFFC9A84C);
  static const Color accent1 = Color(0xFFE8C97A);
  static const Color accent2 = Color(0xFF8C977A);
  static const Color accentSoft = Color(0xFFFBF3DD);
  static const Color accentInk = Color(0xFF6E551A);

  static const Color heroGradTop = Color(0xFF1A2A6E);
  static const Color navyDark = Color(0xFF002B5B);
  static const Color heroGradBottom = Color(0xFF0A1230);
  static const Color scaffoldDarkTop = Color(0xFF07091E);
  static const Color textDark = Color(0xFF0D1B4B);

  // =========================
  // GOLD PALETTE
  // =========================

  static const gold = Color(0xFFD8A93A);
  static const goldLight = Color(0xFFF3CE6B);
  static const goldDeep = Color(0xFFD4AF37);
  static const yellow = Color(0xFFFFD700);
  static const gold1 = Color(0xFFd4ad52);
  static const gold100 = Color(0xFFEBcf7f);
  static const gold500 = Color(0xFFc3942d);
  static const gold800 = Color(0xFF5a4414);
  static const heroText1 = Color(0xFF231806);


  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF1F4FB);

  // =========================
  // TEXT / INK
  // =========================

  static const Color ink = Color(0xFF0E1525);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textGrey = Color(0xFF8A8FA3);
  static const Color inkMid = Color(0xFF5C6578);
  static const Color inkDim = Color(0xFF97A0B2);

  // =========================
  // BORDERS
  // =========================

  static const Color line = Color(0xFFE7EBF3);
  static const Color line2 = Color(0xFFEFF2F8);

  // =========================
  // SEMANTIC COLORS
  // =========================

  static const Color green = Color(0xFF1E9E62);
  static const Color greenSoft = Color(0xFFE2F4EA);

  static const Color red = Color(0xFFE0533B);
  static const Color amber = Color(0xFFE0913B);

  // =========================
  // EXTRA COMMON COLORS
  // =========================

  static const Color black = Color(0xFF000000);

  // =========================
  // VAULT EXPERIENCE SELECTOR (top nav: TheVaults / Vaults Luxe / Ultra Luxe)
  // =========================
  static const Color vaultSelectorPrimary = Color(0xFF5B2A86);
  static const Color vaultSelectorLavender = Color(0xFF8E6BBE);
  static const Color vaultSelectorVeryLightLavender = Color(0xFFF8F5FC);
  static const Color vaultSelectorText = Color(0xFF241A2F);
  static const Color vaultSelectorSecondaryText = Color(0xFF77717F);

  /// Unselected experience tab border — the fill itself now washes from
  /// [vaultHeaderGradientTop] to white, so only the border needs its own
  /// colour.
  static const Color vaultTabUnselectedBorder = Color(0xFFE1D5E9);

  /// Continuous 3-stop gradient behind the experience selector + search row
  /// (top → middle; the bottom stop reuses [vaultSelectorVeryLightLavender]).
  static const Color vaultHeaderGradientTop = Color(0xFFE8D5F5);
  static const Color vaultHeaderGradientMiddle = Color(0xFFF0E5F8);

  /// Search bar border once it sits on the lavender gradient header.
  static const Color vaultSearchBorder = Color(0xFFE8DDF3);

  // =========================
  // DASHBOARD VAULT EXPERIENCE THEMES
  // (upper dashboard area: status bar → TheVaults/Vaults Luxe/Ultra Luxe
  // selector → search bar → heart/cart icons → category tabs). Consumed via
  // [VaultThemeColors] — never reference these hex values directly from a
  // widget.
  // =========================

  // ── TheVaults — lavender / purple ──────────────────────────
  static const Color dashboardTheVaultsHeaderTop = Color(0xFFDCC8EE);
  static const Color dashboardTheVaultsHeaderMiddle = Color(0xFFE9DDF3);
  static const Color dashboardTheVaultsHeaderBottom = Color(0xFFF8F4FB);
  static const Color dashboardTheVaultsPrimary = Color(0xFF5B2A86);
  static const Color dashboardTheVaultsSecondary = Color(0xFF7B4BA3);
  static const Color dashboardTheVaultsSelectedTab = Color(0xFF5B2A86);
  static const Color dashboardTheVaultsUnselectedTab = Color(0xFFF4ECF9);
  static const Color dashboardTheVaultsText = Color(0xFF3F2456);
  static const Color dashboardTheVaultsActiveCategory = Color(0xFF5B2A86);
  static const Color dashboardTheVaultsSearchIcon = Color(0xFF5B2A86);
  static const Color dashboardTheVaultsCartIcon = Color(0xFF5B2A86);
  static const Color dashboardTheVaultsPageBackground = Color(0xFFFFFFFF);
  static const Color dashboardTheVaultsSectionBackground = Color(0xFFF8F4FB);
  static const Color dashboardTheVaultsCardBackground = Color(0xFFFFFFFF);
  static const Color dashboardTheVaultsBorder = Color(0xFFE3D5ED);

  // ── Vaults Luxe — champagne / gold ─────────────────────────
  static const Color dashboardLuxeHeaderTop = Color(0xFFEBD5B5);
  static const Color dashboardLuxeHeaderMiddle = Color(0xFFF3E3CA);
  static const Color dashboardLuxeHeaderBottom = Color(0xFFFBF6ED);
  static const Color dashboardLuxePrimary = Color(0xFFA06B1F);
  static const Color dashboardLuxeSecondary = Color(0xFFC59645);
  static const Color dashboardLuxeSelectedTab = Color(0xFFA06B1F);
  static const Color dashboardLuxeUnselectedTab = Color(0xFFFCF4E6);
  static const Color dashboardLuxeText = Color(0xFF5A421A);
  static const Color dashboardLuxeActiveCategory = Color(0xFFA06B1F);
  static const Color dashboardLuxeSearchIcon = Color(0xFFA06B1F);
  static const Color dashboardLuxeCartIcon = Color(0xFFA06B1F);
  static const Color dashboardLuxePageBackground = Color(0xFFFFFCF6);
  static const Color dashboardLuxeSectionBackground = Color(0xFFFBF6ED);
  static const Color dashboardLuxeCardBackground = Color(0xFFFFFDF8);
  static const Color dashboardLuxeBorder = Color(0xFFE8D3AE);

  // ── Ultra Luxe — deep plum / black + gold ──────────────────
  static const Color dashboardUltraHeaderTop = Color(0xFF24102F);
  static const Color dashboardUltraHeaderMiddle = Color(0xFF3B1D4D);
  static const Color dashboardUltraHeaderBottom = Color(0xFF5A326D);
  static const Color dashboardUltraPrimary = Color(0xFFF3CE6B);
  static const Color dashboardUltraSecondary = Color(0xFFD8A93A);
  static const Color dashboardUltraSelectedTab = Color(0xFF1A0B24);
  static const Color dashboardUltraUnselectedTab = Color(0xFF3A2350);
  static const Color dashboardUltraText = Color(0xFFFFFFFF);
  static const Color dashboardUltraActiveCategory = Color(0xFFF3CE6B);
  // Search icon stays TheVaults-purple even on Ultra Luxe's white search
  // field, per design spec.
  static const Color dashboardUltraSearchIcon = Color(0xFF5B2A86);
  static const Color dashboardUltraCartIcon = Color(0xFFF3CE6B);
  static const Color dashboardUltraPageBackground = Color(0xFF170C20);
  static const Color dashboardUltraSectionBackground = Color(0xFF24102F);
  static const Color dashboardUltraCardBackground = Color(0xFF2F183C);
  static const Color dashboardUltraBorder = Color(0xFF6B477A);
  static const Color dashboardUltraSecondaryText = Color(0xFFE7DDF0);
  // Text-on-button colour for Ultra Luxe's gold (#D8A93A) buttons — needs a
  // dark ink for contrast, unlike TheVaults/Luxe whose buttons stay solid
  // enough for white text.
  static const Color dashboardUltraButtonText = Color(0xFF1A0B24);

  // =========================
  // MEMBERSHIP PLAN CARDS (Choose Your Plan redesign)
  // =========================
  static const Color membershipPrimaryPurple = Color(0xFF5B2A86);
  static const Color membershipMediumPurple = Color(0xFF6F3A9A);
  static const Color membershipLavender = Color(0xFF8E6BBE);
  static const Color membershipLightLavender = Color(0xFFE8DDF3);
  static const Color membershipVeryLightLavender = Color(0xFFF8F5FC);
  static const Color membershipGold = Color(0xFFD8A93A);
  static const Color membershipGoldLight = Color(0xFFF3CE6B);
  static const Color membershipTextDark = Color(0xFF241A2F);
  static const Color membershipTextSecondary = Color(0xFF77717F);

  /// TheVaults tier (entry) — purple/lavender.
  static const Color membershipEssentialBg = Color(0xFFF8F5FC);
  static const Color membershipEssentialBorder = Color(0xFF8E6BBE);

  /// Vaults Luxe tier (mid) — champagne/gold.
  static const Color membershipLuxeBg = Color(0xFFFFFCF5);
  static const Color membershipLuxeBorder = Color(0xFFE8C872);
  static const Color membershipLuxeAccent = Color(0xFFC58A18);
  static const Color membershipLuxeText = Color(0xFF5A421A);

  /// Ultra Luxe tier (top) — dark + gold.
  static const Color membershipUltraBg = Color(0xFF18131F);
  static const Color membershipUltraAccent = Color(0xFFF3CE6B);

  // =========================
  // AUCTION HERO (gold-on-navy spotlight card)
  // =========================
  static const Color auctionHeroBackground = Color(0xFF0B1324);
  static const Color auctionGold = Color(0xFFE4B94F);

  // =========================
  // DARK MODE PALETTE  (NEW)
  // =========================
  static const Color darkBackground = Color(0xFF0A0A0B);
  static const Color darkSurface = Color(0xFF151517);
  static const Color darkSurfaceAlt = Color(0xFF1C1C1F);
  static const Color darkBorder = Color(0xFF2A2A2E);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextMuted = Color(0xFF6E6E76);
  static const Color darkPurple = Color(0xFF8B5CF6);
  static const Color darkPurpleSoft = Color(0xFF2A1B45);

  // Hero banner (NEW)
  static const LinearGradient heroBannerLight = LinearGradient(
    colors: [Color(0xFFEDE6F5), Color(0xFFDCD0EA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const LinearGradient heroBannerDark = LinearGradient(
    colors: [Color(0xFF1E1330), Color(0xFF2A1B45)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryGradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepPurple, primaryPurple, mediumPurple],
  );

  // Benefits strip (NEW)
  static const LinearGradient benefitsStripLight = LinearGradient(
    colors: [Color(0xFF7B50AB), Color(0xFFA48BC2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const LinearGradient benefitsStripDark = LinearGradient(
    colors: [Color(0xFF1C1C1F), Color(0xFF1C1C1F)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient primaryGradient = LinearGradient(
    colors: [blue, blueDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient goldGradient = LinearGradient(
    colors: [accent, accentInk],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    colors: [gold100, gold1, gold500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onboardingDarkBg = LinearGradient(
    colors: [Color(0xFF0B0F26), Color(0xFF0E1533), Color(0xFF13205A)],
    stops: [0.0, 0.45, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // static const LinearGradient buttonBackGroundColor = LinearGradient(
  //   colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
  //   begin: Alignment.centerLeft,
  //   end: Alignment.centerRight,
  // );

  static const LinearGradient banner = LinearGradient(
    colors: [Color(0xFFEDE6F5), Color(0xFFDCD0EA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient bottomSection = LinearGradient(
    colors: [Color(0xFF7B50AB), Color(0xFFA48BC2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient bookServiceBackground = LinearGradient(
    colors: [Color(0xFFFDF4ED), Color(0xFFF8EEF4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      primaryPurple,
      mediumPurple,
    ],
  );

  static const LinearGradient secondaryButtonGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF3ECF8),
        Color(0xFFE9DDF1),
      ],
  );
}
