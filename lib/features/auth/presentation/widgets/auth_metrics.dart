import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

double _cl(double v, double lo, double hi) => v.clamp(lo, hi).toDouble();

class AuthMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double pagePadH;
  final double pagePadV;
  final double fieldGap;
  final double blockGap;
  final double sectionGap;
  final double paneGap;

  final double logoBox;
  final double brandTitle;
  final double brandTagline;

  final double heroTitle;
  final double heroBody;
  final double heroImageMax;
  final double heroImageMaxH;

  final double contentMaxWidth;
  final double formMaxWidth;
  final double buttonHeight;
  final double buttonRadius;
  final double linkText;
  final double footerText;

  final double featureIconBox;
  final double featureTitle;
  final double featureBody;

  const AuthMetrics._({
    required this.isTablet,
    required this.isLandscape,
    required this.pagePadH,
    required this.pagePadV,
    required this.fieldGap,
    required this.blockGap,
    required this.sectionGap,
    required this.paneGap,
    required this.logoBox,
    required this.brandTitle,
    required this.brandTagline,
    required this.heroTitle,
    required this.heroBody,
    required this.heroImageMax,
    required this.heroImageMaxH,
    required this.contentMaxWidth,
    required this.formMaxWidth,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.linkText,
    required this.footerText,
    required this.featureIconBox,
    required this.featureTitle,
    required this.featureBody,
  });

  factory AuthMetrics.of(BoxConstraints b) {
    final w = b.maxWidth;
    final h = b.maxHeight;
    final isLandscape = w > h;

    // ---------------- PHONE ----------------
    if (!ResponsiveUtils.isTablet) {
      final k = _cl(w / 390, 0.88, 1.12);

      return AuthMetrics._(
        isTablet: false,
        isLandscape: isLandscape,
        pagePadH: 20 * k,
        pagePadV: 16 * k,
        fieldGap: 18 * k,
        blockGap: 24 * k,
        sectionGap: 30 * k,
        paneGap: 0,
        logoBox: 44 * k,
        brandTitle: 24 * k,
        brandTagline: 9 * k,
        heroTitle: 30 * k,
        heroBody: 15 * k,
        heroImageMax: w * 0.42,
        heroImageMaxH: _cl(w * 0.44, 130, 190),
        contentMaxWidth: double.infinity,
        formMaxWidth: double.infinity,
        buttonHeight: 54 * k,
        buttonRadius: 14,
        linkText: 14 * k,
        footerText: 12 * k,
        featureIconBox: 44 * k,
        featureTitle: 14 * k,
        featureBody: 12 * k,
      );
    }

    // ---------------- TABLET LANDSCAPE ----------------
    if (isLandscape) {
      return AuthMetrics._(
        isTablet: true,
        isLandscape: true,
        pagePadH: w * 0.030, // 0.035 → 0.030
        pagePadV: _cl(h * 0.035, 14, 28), // height bachai
        fieldGap: 18,
        blockGap: 22, // 28 → 22
        sectionGap: 36,
        paneGap: w * 0.012, // 0.025 → 0.012  (image ↔ form gap kam)
        logoBox: 46,
        brandTitle: _cl(w * 0.024, 24, 34),
        brandTagline: _cl(w * 0.010, 11, 14),
        heroTitle: _cl(w * 0.032, 30, 46),
        heroBody: _cl(w * 0.013, 14, 18),
        heroImageMax: _cl(w * 0.34, 280, 520),
        heroImageMaxH: _cl(h * 0.42, 220, 400), // image thoda chhota
        contentMaxWidth: double.infinity,
        formMaxWidth: _cl(w * 0.36, 400, 520), // 380–460 → 400–520 (form bada)
        buttonHeight: 54,
        buttonRadius: 12,
        linkText: _cl(w * 0.011, 13, 16),
        footerText: _cl(w * 0.010, 12, 15),
        featureIconBox: _cl(w * 0.035, 44, 60),
        featureTitle: _cl(w * 0.013, 15, 18),
        featureBody: _cl(w * 0.011, 13, 16),
      );
    }

    // ---------------- TABLET PORTRAIT ----------------
    return AuthMetrics._(
      isTablet: true,
      isLandscape: false,
      pagePadH: w * 0.035,
      pagePadV: _cl(h * 0.04, 24, 48),
      fieldGap: 18,
      blockGap: 26,
      sectionGap: 34,
      paneGap: 0,
      logoBox: 52,
      brandTitle: _cl(w * 0.036, 24, 32),
      brandTagline: _cl(w * 0.015, 11, 14),
      heroTitle: _cl(w * 0.052, 30, 42),
      heroBody: _cl(w * 0.022, 15, 19),
      heroImageMax: _cl(w * 0.46, 260, 440),
      heroImageMaxH: _cl(h * 0.20, 160, 260),

      contentMaxWidth: _cl(w * 0.88, 480, 760),
      formMaxWidth: _cl(w * 0.88, 480, 760),
      buttonHeight: 54,
      buttonRadius: 12,
      linkText: _cl(w * 0.019, 14, 17),
      footerText: _cl(w * 0.017, 13, 16),
      featureIconBox: _cl(w * 0.075, 46, 60),
      featureTitle: _cl(w * 0.021, 15, 18),
      featureBody: _cl(w * 0.018, 13, 16),
    );
  }
}
