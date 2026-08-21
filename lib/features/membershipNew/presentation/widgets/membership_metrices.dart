import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

/// SINGLE SOURCE OF TRUTH — membership ke saare screens isi ko use karte hain:
///   * MembershipScreen           (API driven)
///   * MembershipLandingScreen
///   * MembershipPlansScreen
///   * MembershipCheckoutScreen
///   * MembershipActivatedScreen
///
/// Phone  -> Sizer units
/// Tablet -> fixed dp * clamped scale (Sizer tablet pe ~1.8x oversize karta hai)
///
/// Tablet detect: MediaQuery.sizeOf(context).shortestSide >= 540
/// (SM-T225 ~553dp, isliye 600 ki jagah 540)
class MembershipMetrics {
  const MembershipMetrics._({
    // ---- device ----
    required this.isTablet,
    required this.isLandscape,

    // ---- spacing ----
    required this.hPad,
    required this.vPad,
    required this.sectionGap,
    required this.rowGap,
    required this.cardPad,
    required this.tileGap,

    // ---- radius ----
    required this.radiusLg,
    required this.radiusMd,
    required this.radiusSm,

    // ---- hero ----
    required this.heroHeight,
    required this.heroTitleSize,
    required this.heroBodySize,
    required this.brandWordSize,

    // ---- type scale ----
    required this.screenTitleSize,
    required this.sectionTitleSize,
    required this.planNameSize,
    required this.priceSize,
    required this.bodySize,
    required this.tileTitleSize,
    required this.tileValueSize,
    required this.labelSize,
    required this.captionSize,

    // ---- icons / controls ----
    required this.iconBox,
    required this.iconSize,
    required this.iconCircle,
    required this.circleIconSize,
    required this.smallIcon,
    required this.radioSize,
    required this.buttonHeight,
    required this.progressHeight,

    // ---- layout ----
    required this.maxContentWidth,
    required this.benefitColumns,
  });

  // ---------------------------------------------------------------- device
  final bool isTablet;
  final bool isLandscape;

  // --------------------------------------------------------------- spacing
  final double hPad;
  final double vPad;
  final double sectionGap;

  /// Chhota vertical gap (elements ke beech).
  final double rowGap;
  final double cardPad;
  final double tileGap;

  // ---------------------------------------------------------------- radius
  final double radiusLg;
  final double radiusMd;
  final double radiusSm;

  // ------------------------------------------------------------------ hero
  final double heroHeight;
  final double heroTitleSize;
  final double heroBodySize;
  final double brandWordSize;

  // ------------------------------------------------------------ type scale
  /// AppBar title
  final double screenTitleSize;

  /// "Membership Benefits", "Choose your plan"
  final double sectionTitleSize;

  final double planNameSize;
  final double priceSize;

  /// Normal body / detail row text
  final double bodySize;

  final double tileTitleSize;
  final double tileValueSize;
  final double labelSize;
  final double captionSize;

  // ------------------------------------------------------- icons / controls
  /// Square icon box (benefit tile ke andar)
  final double iconBox;

  /// iconBox ke andar icon ka size
  final double iconSize;

  /// Round icon circle (benefits strip, info strip)
  final double iconCircle;

  /// iconCircle ke andar icon ka size
  final double circleIconSize;

  final double smallIcon;
  final double radioSize;
  final double buttonHeight;
  final double progressHeight;

  // ---------------------------------------------------------------- layout
  final double maxContentWidth;

  /// Entitlement grid columns (phone 1, tablet 2)
  final int benefitColumns;

  // ================================================================ getters

  static const double tabletBreakpoint = 540;

  bool get isPhone => !isTablet;
  bool get isTabletPortrait => isTablet && !isLandscape;
  bool get isTabletLandscape => isTablet && isLandscape;

  /// Benefits strip: phone portrait -> 2x2, warna 4 columns ek row me
  bool get stripTwoByTwo => isPhone && !isLandscape;

  // ---- back-compat aliases (purane naam bhi chalte rahenge) ----
  double get gap => rowGap;
  double get sectionTitle => sectionTitleSize;
  double get screenTitle => screenTitleSize;
  double get heroTitle => heroTitleSize;
  double get heroBody => heroBodySize;
  double get brandWord => brandWordSize;
  double get badgeIcon => smallIcon;

  // =============================================================== factory

  factory MembershipMetrics.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= tabletBreakpoint;
    final isLandscape = size.width > size.height;

    // ------------------------------------------------------------- PHONE
    if (!isTablet) {
      return MembershipMetrics._(
        isTablet: false,
        isLandscape: isLandscape,

        hPad: 4.5.w,
        vPad: 1.2.h,
        sectionGap: 3.h,
        rowGap: 1.5.h,
        cardPad: 4.w,
        tileGap: 1.4.h,

        radiusLg: 5.w,
        radiusMd: 3.6.w,
        radiusSm: 2.4.w,

        heroHeight: 27.h,
        heroTitleSize: 21.sp,
        heroBodySize: 12.sp,
        brandWordSize: 15.sp,

        screenTitleSize: 17.sp,
        sectionTitleSize: 16.sp,
        planNameSize: 17.sp,
        priceSize: 21.sp,
        bodySize: 13.sp,
        tileTitleSize: 13.5.sp,
        tileValueSize: 11.5.sp,
        labelSize: 12.5.sp,
        captionSize: 10.5.sp,

        iconBox: 11.w,
        iconSize: 5.2.w,
        iconCircle: 14.w,
        circleIconSize: 6.4.w,
        smallIcon: 4.6.w,
        radioSize: 5.6.w,
        buttonHeight: 6.6.h,
        progressHeight: 1.6.w,

        maxContentWidth: double.infinity,
        benefitColumns: 1,
      );
    }

    // ------------------------------------------------------------ TABLET
    // Sizer ki jagah fixed dp, shortestSide se scale + clamp.
    final scale = (size.shortestSide / 800).clamp(0.88, 1.14);
    double d(double v) => v * scale;

    return MembershipMetrics._(
      isTablet: true,
      isLandscape: isLandscape,

      hPad: d(isLandscape ? 34 : 28),
      vPad: d(10),
      sectionGap: d(28),
      rowGap: d(15),
      cardPad: d(22),
      tileGap: d(14),

      radiusLg: d(24),
      radiusMd: d(18),
      radiusSm: d(12),

      heroHeight: isLandscape ? d(300) : d(330),
      heroTitleSize: d(34),
      heroBodySize: d(15),
      brandWordSize: d(20),

      screenTitleSize: d(22),
      sectionTitleSize: d(21),
      planNameSize: d(22),
      priceSize: d(30),
      bodySize: d(16),
      tileTitleSize: d(16),
      tileValueSize: d(13.5),
      labelSize: d(15),
      captionSize: d(13),

      iconBox: d(48),
      iconSize: d(23),
      iconCircle: d(66),
      circleIconSize: d(30),
      smallIcon: d(20),
      radioSize: d(24),
      buttonHeight: d(58),
      progressHeight: d(8),

      maxContentWidth: isLandscape ? d(1120) : d(820),
      benefitColumns: 2,
    );
  }
}