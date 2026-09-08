import 'package:flutter/material.dart';

class BookingDetailsMetrics {
  const BookingDetailsMetrics({
    required this.isTablet,
    required this.maxContentWidth,

    required this.dialogRadius,
    required this.dialogIconBox,
    required this.dialogIconSize,
    required this.dialogGapLg,
    required this.dialogTitleSize,
    required this.dialogGapSm,
    required this.dialogBodySize,

    required this.headerHeight,
    required this.headerPadLeft,
    required this.headerPadRight,
    required this.headerBackSplash,
    required this.headerBackIconSize,
    required this.headerTitleGapW,
    required this.headerTitleSize,
    required this.headerTitleGapH,
    required this.headerSubtitleSize,

    required this.pagePadH,
    required this.pagePadTop,
    required this.pagePadBottom,
    required this.sectionGap,
    required this.sectionTitleGap,
    required this.bottomActionsGap,

    required this.heroRadius,
    required this.heroShadowBlur,
    required this.heroShadowOffsetY,
    required this.heroTopBarHeight,
    required this.heroPadH,
    required this.heroPadTop,
    required this.heroPadBottom,
    required this.heroIconBox,
    required this.heroIconRadius,
    required this.heroIconSize,
    required this.heroTitleGapW,
    required this.heroSubtitleGapH,
    required this.heroSubtitleSize,
    required this.heroBadgeGapW,
    required this.heroMetaGapH,
    required this.heroMetaPad,
    required this.heroMetaRadius,
    required this.heroDividerHeight,

    required this.heroMetaHPad,
    required this.heroMetaIconSize,
    required this.heroMetaIconGapW,
    required this.heroMetaLabelSize,
    required this.heroMetaLabelGapH,
    required this.heroMetaValueSize,

    required this.sectionIconSize,
    required this.sectionIconGapW,
    required this.sectionTitleTextSize,

    required this.apptBoxW,
    required this.apptBoxH,
    required this.apptBoxRadius,
    required this.apptMonthSize,
    required this.apptDateGapH,
    required this.apptDaySize,
    required this.apptTextGapW,
    required this.apptDateTextSize,
    required this.apptTimeGapH,
    required this.apptTimeIconSize,
    required this.apptTimeIconGapW,
    required this.apptTimeTextSize,
    required this.apptDividerGapH,
    required this.apptInfoGapH,
    required this.apptInfoIconSize,
    required this.apptInfoIconGapW,
    required this.apptInfoTextSize,

    required this.providerIconBox,
    required this.providerIconRadius,
    required this.providerIconSize,
    required this.providerTextGapW,
    required this.providerTitleSize,
    required this.providerSubtitleGapH,
    required this.providerSubtitleSize,
    required this.providerCheckSize,

    required this.addressIconBox,
    required this.addressIconRadius,
    required this.addressIconSize,
    required this.addressTextGapW,
    required this.addressNameSize,
    required this.addressLineGapH,
    required this.addressLineSize,
    required this.addressPhoneSize,

    required this.paymentModeSize,
    required this.paymentStatusGapH,
    required this.paymentStatusSize,
    required this.paymentPriceSize,
    required this.paymentBannerGapH,
    required this.paymentBannerHPad,
    required this.paymentBannerVPad,
    required this.paymentBannerRadius,
    required this.paymentBannerIconSize,
    required this.paymentBannerIconGapW,
    required this.paymentBannerTextSize,

    required this.timelineTitleSize,
    required this.timelineTitleGapH,
    required this.timelineEmptySize,

    required this.timelineDotColW,
    required this.timelineDotSize,
    required this.timelineLineH,
    required this.timelineTextGapW,
    required this.timelineItemPadBottom,
    required this.timelineItemTitleSize,
    required this.timelineItemGapH,
    required this.timelineItemSubtitleSize,

    required this.cardPad,
    required this.cardRadius,
    required this.cardShadowBlur,
    required this.cardShadowOffsetY,

    required this.detailIconBox,
    required this.detailIconRadius,
    required this.detailIconSize,
    required this.detailGapW,
    required this.detailLabelSize,
    required this.detailValueSize,

    required this.dividerVPad,

    required this.badgeMaxWidth,
    required this.badgeHPad,
    required this.badgeVPad,
    required this.badgeRadius,
    required this.badgeFontSize,

    required this.changeTimeBtnHeight,
    required this.changeTimeIconSize,
    required this.changeTimeRadius,
    required this.changeTimeFontSize,
    required this.actionsGap,
    required this.slideHintGapH,
    required this.slideHintSize,
    required this.reschedulingTextSize,

    required this.slotsLoadingHeight,
    required this.slotsSpinnerSize,
    required this.slotsMsgGapH,
    required this.slotsMsgSize,
    required this.slotsErrorIconSize,
    required this.slotsHeaderPadH,
    required this.slotsHeaderPadTop,
    required this.slotsHeaderPadBottom,
    required this.slotsHeaderTitleSize,
    required this.slotsListHeight,

    required this.dayHeaderPadBottom,
    required this.dayLabelSize,
    required this.daySlotsSpacing,
    required this.dayBottomGapH,

    required this.slotRadius,
    required this.slotHPad,
    required this.slotVPad,
    required this.slotTextSize,

    required this.cancelFieldGapH,
    required this.cancelFieldRadius,

    required this.slideHandleSize,
    required this.slideHPad,
    required this.slideHeight,
    required this.slideRadius,
    required this.slideShadowBlur,
    required this.slideShadowOffsetY,
    required this.slideInnerRadius,
    required this.slideTextSize,
    required this.slideChevronRightPad,
    required this.slideHandleShadowBlur,
    required this.slideHandleShadowOffsetY,
    required this.slideCheckIconSize,
    required this.slideArrowIconSize,

    required this.chevronIconSize,

    required this.loadingHeaderPadH,
    required this.loadingHeaderPadTop,
    required this.loadingHeaderPadBottom,
    required this.loadingAvatarBox,
    required this.loadingAvatarRadius,
    required this.loadingAvatarGapW,
    required this.loadingTitleWidth,
    required this.loadingTitleHeight,
    required this.loadingTitleRadius,
    required this.loadingTitleGapH,
    required this.loadingSubWidth,
    required this.loadingSubHeight,
    required this.loadingSubRadius,
    required this.loadingListPadH,
    required this.loadingListPadTop,
    required this.loadingListPadBottom,
    required this.loadingCardGapH,

    required this.loadingCardPad,
    required this.loadingCardRadius,
    required this.loadingLine1Width,
    required this.loadingLine1Height,
    required this.loadingLine1Radius,
    required this.loadingGap1,
    required this.loadingLine2Height,
    required this.loadingLine2Radius,
    required this.loadingGap2,
    required this.loadingLine3Width,
    required this.loadingGap3,
    required this.loadingGap4,
    required this.loadingLine4Width,
    required this.loadingLine4Height,
    required this.loadingLine4Radius,

    required this.errorIconBox,
    required this.errorIconSize,
    required this.errorGap1,
    required this.errorTitleSize,
    required this.errorGap2,
    required this.errorBodySize,
    required this.errorGap3,
    required this.errorBtnHeight,
    required this.errorBtnRadius,
  });

  final bool isTablet;
  final double maxContentWidth;

  final double dialogRadius;
  final double dialogIconBox;
  final double dialogIconSize;
  final double dialogGapLg;
  final double dialogTitleSize;
  final double dialogGapSm;
  final double dialogBodySize;

  final double headerHeight;
  final double headerPadLeft;
  final double headerPadRight;
  final double headerBackSplash;
  final double headerBackIconSize;
  final double headerTitleGapW;
  final double headerTitleSize;
  final double headerTitleGapH;
  final double headerSubtitleSize;

  final double pagePadH;
  final double pagePadTop;
  final double pagePadBottom;
  final double sectionGap;
  final double sectionTitleGap;
  final double bottomActionsGap;

  final double heroRadius;
  final double heroShadowBlur;
  final double heroShadowOffsetY;
  final double heroTopBarHeight;
  final double heroPadH;
  final double heroPadTop;
  final double heroPadBottom;
  final double heroIconBox;
  final double heroIconRadius;
  final double heroIconSize;
  final double heroTitleGapW;
  final double heroSubtitleGapH;
  final double heroSubtitleSize;
  final double heroBadgeGapW;
  final double heroMetaGapH;
  final double heroMetaPad;
  final double heroMetaRadius;
  final double heroDividerHeight;

  final double heroMetaHPad;
  final double heroMetaIconSize;
  final double heroMetaIconGapW;
  final double heroMetaLabelSize;
  final double heroMetaLabelGapH;
  final double heroMetaValueSize;

  final double sectionIconSize;
  final double sectionIconGapW;
  final double sectionTitleTextSize;

  final double apptBoxW;
  final double apptBoxH;
  final double apptBoxRadius;
  final double apptMonthSize;
  final double apptDateGapH;
  final double apptDaySize;
  final double apptTextGapW;
  final double apptDateTextSize;
  final double apptTimeGapH;
  final double apptTimeIconSize;
  final double apptTimeIconGapW;
  final double apptTimeTextSize;
  final double apptDividerGapH;
  final double apptInfoGapH;
  final double apptInfoIconSize;
  final double apptInfoIconGapW;
  final double apptInfoTextSize;

  final double providerIconBox;
  final double providerIconRadius;
  final double providerIconSize;
  final double providerTextGapW;
  final double providerTitleSize;
  final double providerSubtitleGapH;
  final double providerSubtitleSize;
  final double providerCheckSize;

  final double addressIconBox;
  final double addressIconRadius;
  final double addressIconSize;
  final double addressTextGapW;
  final double addressNameSize;
  final double addressLineGapH;
  final double addressLineSize;
  final double addressPhoneSize;

  final double paymentModeSize;
  final double paymentStatusGapH;
  final double paymentStatusSize;
  final double paymentPriceSize;
  final double paymentBannerGapH;
  final double paymentBannerHPad;
  final double paymentBannerVPad;
  final double paymentBannerRadius;
  final double paymentBannerIconSize;
  final double paymentBannerIconGapW;
  final double paymentBannerTextSize;

  final double timelineTitleSize;
  final double timelineTitleGapH;
  final double timelineEmptySize;

  final double timelineDotColW;
  final double timelineDotSize;
  final double timelineLineH;
  final double timelineTextGapW;
  final double timelineItemPadBottom;
  final double timelineItemTitleSize;
  final double timelineItemGapH;
  final double timelineItemSubtitleSize;

  final double cardPad;
  final double cardRadius;
  final double cardShadowBlur;
  final double cardShadowOffsetY;

  final double detailIconBox;
  final double detailIconRadius;
  final double detailIconSize;
  final double detailGapW;
  final double detailLabelSize;
  final double detailValueSize;

  final double dividerVPad;

  final double badgeMaxWidth;
  final double badgeHPad;
  final double badgeVPad;
  final double badgeRadius;
  final double badgeFontSize;

  final double changeTimeBtnHeight;
  final double changeTimeIconSize;
  final double changeTimeRadius;
  final double changeTimeFontSize;
  final double actionsGap;
  final double slideHintGapH;
  final double slideHintSize;
  final double reschedulingTextSize;

  final double slotsLoadingHeight;
  final double slotsSpinnerSize;
  final double slotsMsgGapH;
  final double slotsMsgSize;
  final double slotsErrorIconSize;
  final double slotsHeaderPadH;
  final double slotsHeaderPadTop;
  final double slotsHeaderPadBottom;
  final double slotsHeaderTitleSize;
  final double slotsListHeight;

  final double dayHeaderPadBottom;
  final double dayLabelSize;
  final double daySlotsSpacing;
  final double dayBottomGapH;

  final double slotRadius;
  final double slotHPad;
  final double slotVPad;
  final double slotTextSize;

  final double cancelFieldGapH;
  final double cancelFieldRadius;

  final double slideHandleSize;
  final double slideHPad;
  final double slideHeight;
  final double slideRadius;
  final double slideShadowBlur;
  final double slideShadowOffsetY;
  final double slideInnerRadius;
  final double slideTextSize;
  final double slideChevronRightPad;
  final double slideHandleShadowBlur;
  final double slideHandleShadowOffsetY;
  final double slideCheckIconSize;
  final double slideArrowIconSize;

  final double chevronIconSize;

  final double loadingHeaderPadH;
  final double loadingHeaderPadTop;
  final double loadingHeaderPadBottom;
  final double loadingAvatarBox;
  final double loadingAvatarRadius;
  final double loadingAvatarGapW;
  final double loadingTitleWidth;
  final double loadingTitleHeight;
  final double loadingTitleRadius;
  final double loadingTitleGapH;
  final double loadingSubWidth;
  final double loadingSubHeight;
  final double loadingSubRadius;
  final double loadingListPadH;
  final double loadingListPadTop;
  final double loadingListPadBottom;
  final double loadingCardGapH;

  final double loadingCardPad;
  final double loadingCardRadius;
  final double loadingLine1Width;
  final double loadingLine1Height;
  final double loadingLine1Radius;
  final double loadingGap1;
  final double loadingLine2Height;
  final double loadingLine2Radius;
  final double loadingGap2;
  final double loadingLine3Width;
  final double loadingGap3;
  final double loadingGap4;
  final double loadingLine4Width;
  final double loadingLine4Height;
  final double loadingLine4Radius;

  final double errorIconBox;
  final double errorIconSize;
  final double errorGap1;
  final double errorTitleSize;
  final double errorGap2;
  final double errorBodySize;
  final double errorGap3;
  final double errorBtnHeight;
  final double errorBtnRadius;

  static BookingDetailsMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;

    if (!isTablet) return BookingDetailsMetrics.phone();
    return isLandscape
        ? BookingDetailsMetrics.tabletLandscape()
        : BookingDetailsMetrics.tabletPortrait();
  }

  factory BookingDetailsMetrics.phone() => const BookingDetailsMetrics(
    isTablet: false,
    maxContentWidth: double.infinity,

    dialogRadius: 20,
    dialogIconBox: 64,
    dialogIconSize: 32,
    dialogGapLg: 16,
    dialogTitleSize: 16,
    dialogGapSm: 8,
    dialogBodySize: 12,

    headerHeight: 58,
    headerPadLeft: 4,
    headerPadRight: 16,
    headerBackSplash: 20,
    headerBackIconSize: 21,
    headerTitleGapW: 2,
    headerTitleSize: 18,
    headerTitleGapH: 2,
    headerSubtitleSize: 11.5,

    pagePadH: 20,
    pagePadTop: 4,
    pagePadBottom: 40,
    sectionGap: 18,
    sectionTitleGap: 10,
    bottomActionsGap: 24,

    heroRadius: 25,
    heroShadowBlur: 25,
    heroShadowOffsetY: 8,
    heroTopBarHeight: 5,
    heroPadH: 20,
    heroPadTop: 20,
    heroPadBottom: 19,
    heroIconBox: 54,
    heroIconRadius: 17,
    heroIconSize: 25,
    heroTitleGapW: 14,
    heroSubtitleGapH: 5,
    heroSubtitleSize: 11,
    heroBadgeGapW: 8,
    heroMetaGapH: 20,
    heroMetaPad: 14,
    heroMetaRadius: 17,
    heroDividerHeight: 32,

    heroMetaHPad: 8,
    heroMetaIconSize: 17,
    heroMetaIconGapW: 8,
    heroMetaLabelSize: 9.5,
    heroMetaLabelGapH: 2,
    heroMetaValueSize: 11,

    sectionIconSize: 16,
    sectionIconGapW: 7,
    sectionTitleTextSize: 14,

    apptBoxW: 62,
    apptBoxH: 68,
    apptBoxRadius: 16,
    apptMonthSize: 10,
    apptDateGapH: 2,
    apptDaySize: 24,
    apptTextGapW: 14,
    apptDateTextSize: 14,
    apptTimeGapH: 8,
    apptTimeIconSize: 16,
    apptTimeIconGapW: 6,
    apptTimeTextSize: 12,
    apptDividerGapH: 15,
    apptInfoGapH: 13,
    apptInfoIconSize: 16,
    apptInfoIconGapW: 7,
    apptInfoTextSize: 11,

    providerIconBox: 48,
    providerIconRadius: 15,
    providerIconSize: 22,
    providerTextGapW: 13,
    providerTitleSize: 14,
    providerSubtitleGapH: 4,
    providerSubtitleSize: 11,
    providerCheckSize: 19,

    addressIconBox: 42,
    addressIconRadius: 13,
    addressIconSize: 20,
    addressTextGapW: 12,
    addressNameSize: 13,
    addressLineGapH: 5,
    addressLineSize: 11.5,
    addressPhoneSize: 11,

    paymentModeSize: 13,
    paymentStatusGapH: 3,
    paymentStatusSize: 10.5,
    paymentPriceSize: 17,
    paymentBannerGapH: 14,
    paymentBannerHPad: 12,
    paymentBannerVPad: 10,
    paymentBannerRadius: 11,
    paymentBannerIconSize: 16,
    paymentBannerIconGapW: 7,
    paymentBannerTextSize: 10.5,

    timelineTitleSize: 13,
    timelineTitleGapH: 18,
    timelineEmptySize: 11,

    timelineDotColW: 20,
    timelineDotSize: 10,
    timelineLineH: 43,
    timelineTextGapW: 10,
    timelineItemPadBottom: 18,
    timelineItemTitleSize: 12,
    timelineItemGapH: 3,
    timelineItemSubtitleSize: 10.5,

    cardPad: 16,
    cardRadius: 19,
    cardShadowBlur: 15,
    cardShadowOffsetY: 4,

    detailIconBox: 32,
    detailIconRadius: 10,
    detailIconSize: 15,
    detailGapW: 10,
    detailLabelSize: 11,
    detailValueSize: 11.5,

    dividerVPad: 13,

    badgeMaxWidth: 95,
    badgeHPad: 9,
    badgeVPad: 6,
    badgeRadius: 20,
    badgeFontSize: 9.5,

    changeTimeBtnHeight: 46,
    changeTimeIconSize: 17,
    changeTimeRadius: 30,
    changeTimeFontSize: 12,
    actionsGap: 14,
    slideHintGapH: 7,
    slideHintSize: 9.5,
    reschedulingTextSize: 11,

    slotsLoadingHeight: 40,
    slotsSpinnerSize: 20,
    slotsMsgGapH: 8,
    slotsMsgSize: 11,
    slotsErrorIconSize: 24,
    slotsHeaderPadH: 16,
    slotsHeaderPadTop: 12,
    slotsHeaderPadBottom: 8,
    slotsHeaderTitleSize: 13,
    slotsListHeight: 320,

    dayHeaderPadBottom: 10,
    dayLabelSize: 10,
    daySlotsSpacing: 8,
    dayBottomGapH: 4,

    slotRadius: 12,
    slotHPad: 12,
    slotVPad: 8,
    slotTextSize: 11,

    cancelFieldGapH: 14,
    cancelFieldRadius: 14,

    slideHandleSize: 50,
    slideHPad: 4,
    slideHeight: 58,
    slideRadius: 30,
    slideShadowBlur: 18,
    slideShadowOffsetY: 5,
    slideInnerRadius: 26,
    slideTextSize: 12,
    slideChevronRightPad: 18,
    slideHandleShadowBlur: 12,
    slideHandleShadowOffsetY: 4,
    slideCheckIconSize: 22,
    slideArrowIconSize: 21,

    chevronIconSize: 18,

    loadingHeaderPadH: 20,
    loadingHeaderPadTop: 14,
    loadingHeaderPadBottom: 16,
    loadingAvatarBox: 42,
    loadingAvatarRadius: 13,
    loadingAvatarGapW: 14,
    loadingTitleWidth: 150,
    loadingTitleHeight: 18,
    loadingTitleRadius: 6,
    loadingTitleGapH: 7,
    loadingSubWidth: 110,
    loadingSubHeight: 11,
    loadingSubRadius: 5,
    loadingListPadH: 20,
    loadingListPadTop: 4,
    loadingListPadBottom: 40,
    loadingCardGapH: 18,

    loadingCardPad: 18,
    loadingCardRadius: 20,
    loadingLine1Width: 130,
    loadingLine1Height: 15,
    loadingLine1Radius: 6,
    loadingGap1: 16,
    loadingLine2Height: 12,
    loadingLine2Radius: 5,
    loadingGap2: 10,
    loadingLine3Width: 220,
    loadingGap3: 20,
    loadingGap4: 18,
    loadingLine4Width: 160,
    loadingLine4Height: 11,
    loadingLine4Radius: 5,

    errorIconBox: 64,
    errorIconSize: 30,
    errorGap1: 16,
    errorTitleSize: 17,
    errorGap2: 7,
    errorBodySize: 12,
    errorGap3: 18,
    errorBtnHeight: 44,
    errorBtnRadius: 24,
  );

  factory BookingDetailsMetrics.tabletPortrait() => const BookingDetailsMetrics(
    isTablet: true,
    maxContentWidth: 640,

    dialogRadius: 24,
    dialogIconBox: 83,
    dialogIconSize: 42,
    dialogGapLg: 21,
    dialogTitleSize: 21,
    dialogGapSm: 10,
    dialogBodySize: 16,

    headerHeight: 70,
    headerPadLeft: 5,
    headerPadRight: 21,
    headerBackSplash: 26,
    headerBackIconSize: 27,
    headerTitleGapW: 3,
    headerTitleSize: 23,
    headerTitleGapH: 3,
    headerSubtitleSize: 15,

    pagePadH: 26,
    pagePadTop: 5,
    pagePadBottom: 52,
    sectionGap: 23,
    sectionTitleGap: 13,
    bottomActionsGap: 31,

    heroRadius: 29,
    heroShadowBlur: 33,
    heroShadowOffsetY: 10,
    heroTopBarHeight: 7,
    heroPadH: 26,
    heroPadTop: 26,
    heroPadBottom: 25,
    heroIconBox: 70,
    heroIconRadius: 21,
    heroIconSize: 33,
    heroTitleGapW: 18,
    heroSubtitleGapH: 7,
    heroSubtitleSize: 14,
    heroBadgeGapW: 10,
    heroMetaGapH: 26,
    heroMetaPad: 18,
    heroMetaRadius: 21,
    heroDividerHeight: 42,

    heroMetaHPad: 10,
    heroMetaIconSize: 22,
    heroMetaIconGapW: 10,
    heroMetaLabelSize: 12,
    heroMetaLabelGapH: 3,
    heroMetaValueSize: 14,

    sectionIconSize: 21,
    sectionIconGapW: 9,
    sectionTitleTextSize: 18,

    apptBoxW: 81,
    apptBoxH: 88,
    apptBoxRadius: 20,
    apptMonthSize: 13,
    apptDateGapH: 3,
    apptDaySize: 31,
    apptTextGapW: 18,
    apptDateTextSize: 18,
    apptTimeGapH: 10,
    apptTimeIconSize: 21,
    apptTimeIconGapW: 8,
    apptTimeTextSize: 16,
    apptDividerGapH: 20,
    apptInfoGapH: 17,
    apptInfoIconSize: 21,
    apptInfoIconGapW: 9,
    apptInfoTextSize: 14,

    providerIconBox: 62,
    providerIconRadius: 19,
    providerIconSize: 29,
    providerTextGapW: 17,
    providerTitleSize: 18,
    providerSubtitleGapH: 5,
    providerSubtitleSize: 14,
    providerCheckSize: 25,

    addressIconBox: 55,
    addressIconRadius: 17,
    addressIconSize: 26,
    addressTextGapW: 16,
    addressNameSize: 17,
    addressLineGapH: 7,
    addressLineSize: 15,
    addressPhoneSize: 14,

    paymentModeSize: 17,
    paymentStatusGapH: 4,
    paymentStatusSize: 14,
    paymentPriceSize: 22,
    paymentBannerGapH: 18,
    paymentBannerHPad: 16,
    paymentBannerVPad: 13,
    paymentBannerRadius: 15,
    paymentBannerIconSize: 21,
    paymentBannerIconGapW: 9,
    paymentBannerTextSize: 14,

    timelineTitleSize: 17,
    timelineTitleGapH: 23,
    timelineEmptySize: 14,

    timelineDotColW: 26,
    timelineDotSize: 13,
    timelineLineH: 52,
    timelineTextGapW: 13,
    timelineItemPadBottom: 23,
    timelineItemTitleSize: 16,
    timelineItemGapH: 4,
    timelineItemSubtitleSize: 14,

    cardPad: 21,
    cardRadius: 23,
    cardShadowBlur: 20,
    cardShadowOffsetY: 5,

    detailIconBox: 42,
    detailIconRadius: 14,
    detailIconSize: 20,
    detailGapW: 13,
    detailLabelSize: 14,
    detailValueSize: 15,

    dividerVPad: 17,

    badgeMaxWidth: 124,
    badgeHPad: 12,
    badgeVPad: 8,
    badgeRadius: 24,
    badgeFontSize: 12,

    changeTimeBtnHeight: 55,
    changeTimeIconSize: 22,
    changeTimeRadius: 34,
    changeTimeFontSize: 16,
    actionsGap: 18,
    slideHintGapH: 9,
    slideHintSize: 12,
    reschedulingTextSize: 14,

    slotsLoadingHeight: 48,
    slotsSpinnerSize: 26,
    slotsMsgGapH: 10,
    slotsMsgSize: 14,
    slotsErrorIconSize: 31,
    slotsHeaderPadH: 21,
    slotsHeaderPadTop: 16,
    slotsHeaderPadBottom: 10,
    slotsHeaderTitleSize: 17,
    slotsListHeight: 384,

    dayHeaderPadBottom: 13,
    dayLabelSize: 13,
    daySlotsSpacing: 10,
    dayBottomGapH: 5,

    slotRadius: 16,
    slotHPad: 16,
    slotVPad: 10,
    slotTextSize: 14,

    cancelFieldGapH: 18,
    cancelFieldRadius: 18,

    slideHandleSize: 65,
    slideHPad: 5,
    slideHeight: 70,
    slideRadius: 34,
    slideShadowBlur: 23,
    slideShadowOffsetY: 6,
    slideInnerRadius: 30,
    slideTextSize: 16,
    slideChevronRightPad: 23,
    slideHandleShadowBlur: 16,
    slideHandleShadowOffsetY: 5,
    slideCheckIconSize: 29,
    slideArrowIconSize: 27,

    chevronIconSize: 23,

    loadingHeaderPadH: 26,
    loadingHeaderPadTop: 18,
    loadingHeaderPadBottom: 21,
    loadingAvatarBox: 55,
    loadingAvatarRadius: 17,
    loadingAvatarGapW: 18,
    loadingTitleWidth: 195,
    loadingTitleHeight: 23,
    loadingTitleRadius: 10,
    loadingTitleGapH: 9,
    loadingSubWidth: 143,
    loadingSubHeight: 14,
    loadingSubRadius: 9,
    loadingListPadH: 26,
    loadingListPadTop: 5,
    loadingListPadBottom: 52,
    loadingCardGapH: 23,

    loadingCardPad: 23,
    loadingCardRadius: 24,
    loadingLine1Width: 169,
    loadingLine1Height: 20,
    loadingLine1Radius: 10,
    loadingGap1: 21,
    loadingLine2Height: 16,
    loadingLine2Radius: 9,
    loadingGap2: 13,
    loadingLine3Width: 286,
    loadingGap3: 26,
    loadingGap4: 23,
    loadingLine4Width: 208,
    loadingLine4Height: 14,
    loadingLine4Radius: 9,

    errorIconBox: 83,
    errorIconSize: 39,
    errorGap1: 21,
    errorTitleSize: 22,
    errorGap2: 9,
    errorBodySize: 16,
    errorGap3: 23,
    errorBtnHeight: 53,
    errorBtnRadius: 28,
  );

  factory BookingDetailsMetrics.tabletLandscape() => const BookingDetailsMetrics(
    isTablet: true,
    maxContentWidth: 880,

    dialogRadius: 22,
    dialogIconBox: 74,
    dialogIconSize: 37,
    dialogGapLg: 18,
    dialogTitleSize: 18,
    dialogGapSm: 9,
    dialogBodySize: 14,

    headerHeight: 64,
    headerPadLeft: 5,
    headerPadRight: 18,
    headerBackSplash: 23,
    headerBackIconSize: 24,
    headerTitleGapW: 2,
    headerTitleSize: 21,
    headerTitleGapH: 2,
    headerSubtitleSize: 13,

    pagePadH: 23,
    pagePadTop: 5,
    pagePadBottom: 46,
    sectionGap: 21,
    sectionTitleGap: 12,
    bottomActionsGap: 28,

    heroRadius: 27,
    heroShadowBlur: 29,
    heroShadowOffsetY: 9,
    heroTopBarHeight: 6,
    heroPadH: 23,
    heroPadTop: 23,
    heroPadBottom: 22,
    heroIconBox: 62,
    heroIconRadius: 19,
    heroIconSize: 29,
    heroTitleGapW: 16,
    heroSubtitleGapH: 6,
    heroSubtitleSize: 13,
    heroBadgeGapW: 9,
    heroMetaGapH: 23,
    heroMetaPad: 16,
    heroMetaRadius: 19,
    heroDividerHeight: 37,

    heroMetaHPad: 9,
    heroMetaIconSize: 20,
    heroMetaIconGapW: 9,
    heroMetaLabelSize: 11,
    heroMetaLabelGapH: 2,
    heroMetaValueSize: 13,

    sectionIconSize: 18,
    sectionIconGapW: 8,
    sectionTitleTextSize: 16,

    apptBoxW: 71,
    apptBoxH: 78,
    apptBoxRadius: 18,
    apptMonthSize: 12,
    apptDateGapH: 2,
    apptDaySize: 28,
    apptTextGapW: 16,
    apptDateTextSize: 16,
    apptTimeGapH: 9,
    apptTimeIconSize: 18,
    apptTimeIconGapW: 7,
    apptTimeTextSize: 14,
    apptDividerGapH: 17,
    apptInfoGapH: 15,
    apptInfoIconSize: 18,
    apptInfoIconGapW: 8,
    apptInfoTextSize: 13,

    providerIconBox: 55,
    providerIconRadius: 17,
    providerIconSize: 25,
    providerTextGapW: 15,
    providerTitleSize: 16,
    providerSubtitleGapH: 5,
    providerSubtitleSize: 13,
    providerCheckSize: 22,

    addressIconBox: 48,
    addressIconRadius: 15,
    addressIconSize: 23,
    addressTextGapW: 14,
    addressNameSize: 15,
    addressLineGapH: 6,
    addressLineSize: 13,
    addressPhoneSize: 13,

    paymentModeSize: 15,
    paymentStatusGapH: 3,
    paymentStatusSize: 12,
    paymentPriceSize: 20,
    paymentBannerGapH: 16,
    paymentBannerHPad: 14,
    paymentBannerVPad: 12,
    paymentBannerRadius: 13,
    paymentBannerIconSize: 18,
    paymentBannerIconGapW: 8,
    paymentBannerTextSize: 12,

    timelineTitleSize: 15,
    timelineTitleGapH: 21,
    timelineEmptySize: 13,

    timelineDotColW: 23,
    timelineDotSize: 12,
    timelineLineH: 47,
    timelineTextGapW: 12,
    timelineItemPadBottom: 21,
    timelineItemTitleSize: 14,
    timelineItemGapH: 3,
    timelineItemSubtitleSize: 12,

    cardPad: 18,
    cardRadius: 21,
    cardShadowBlur: 17,
    cardShadowOffsetY: 5,

    detailIconBox: 37,
    detailIconRadius: 12,
    detailIconSize: 17,
    detailGapW: 12,
    detailLabelSize: 13,
    detailValueSize: 13,

    dividerVPad: 15,

    badgeMaxWidth: 109,
    badgeHPad: 10,
    badgeVPad: 7,
    badgeRadius: 22,
    badgeFontSize: 11,

    changeTimeBtnHeight: 51,
    changeTimeIconSize: 20,
    changeTimeRadius: 32,
    changeTimeFontSize: 14,
    actionsGap: 16,
    slideHintGapH: 8,
    slideHintSize: 11,
    reschedulingTextSize: 13,

    slotsLoadingHeight: 44,
    slotsSpinnerSize: 23,
    slotsMsgGapH: 9,
    slotsMsgSize: 13,
    slotsErrorIconSize: 28,
    slotsHeaderPadH: 18,
    slotsHeaderPadTop: 14,
    slotsHeaderPadBottom: 9,
    slotsHeaderTitleSize: 15,
    slotsListHeight: 352,

    dayHeaderPadBottom: 12,
    dayLabelSize: 12,
    daySlotsSpacing: 9,
    dayBottomGapH: 5,

    slotRadius: 14,
    slotHPad: 14,
    slotVPad: 9,
    slotTextSize: 13,

    cancelFieldGapH: 16,
    cancelFieldRadius: 16,

    slideHandleSize: 57,
    slideHPad: 5,
    slideHeight: 64,
    slideRadius: 32,
    slideShadowBlur: 21,
    slideShadowOffsetY: 6,
    slideInnerRadius: 28,
    slideTextSize: 14,
    slideChevronRightPad: 21,
    slideHandleShadowBlur: 14,
    slideHandleShadowOffsetY: 5,
    slideCheckIconSize: 25,
    slideArrowIconSize: 24,

    chevronIconSize: 21,

    loadingHeaderPadH: 23,
    loadingHeaderPadTop: 16,
    loadingHeaderPadBottom: 18,
    loadingAvatarBox: 48,
    loadingAvatarRadius: 15,
    loadingAvatarGapW: 16,
    loadingTitleWidth: 173,
    loadingTitleHeight: 21,
    loadingTitleRadius: 8,
    loadingTitleGapH: 8,
    loadingSubWidth: 127,
    loadingSubHeight: 13,
    loadingSubRadius: 7,
    loadingListPadH: 23,
    loadingListPadTop: 5,
    loadingListPadBottom: 46,
    loadingCardGapH: 21,

    loadingCardPad: 21,
    loadingCardRadius: 22,
    loadingLine1Width: 150,
    loadingLine1Height: 17,
    loadingLine1Radius: 8,
    loadingGap1: 18,
    loadingLine2Height: 14,
    loadingLine2Radius: 7,
    loadingGap2: 12,
    loadingLine3Width: 253,
    loadingGap3: 23,
    loadingGap4: 21,
    loadingLine4Width: 184,
    loadingLine4Height: 13,
    loadingLine4Radius: 7,

    errorIconBox: 74,
    errorIconSize: 35,
    errorGap1: 18,
    errorTitleSize: 20,
    errorGap2: 8,
    errorBodySize: 14,
    errorGap3: 21,
    errorBtnHeight: 48,
    errorBtnRadius: 26,
  );
}
