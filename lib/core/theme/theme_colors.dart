import 'dart:ui';

import 'package:flutter/cupertino.dart';

class ThemeColors {
  // =========================
  // BLUE PALETTE
  // =========================

  static const Color blue = Color(0xFF1B4AE4);
  static const Color blueDeep = Color(0xFF0E2A78);
  static const Color bluePress = Color(0xFF1740BF);
  static const Color blueSoft = Color(0xFFE7EDFD);

  // =========================
  // GOLD PALETTE
  // =========================

  static const Color accent = Color(0xFFC9A84C);
  static const Color accent1 = Color(0xFFE8C97A);
  static const Color accent2 = Color(0xFF8C977A);
  static const Color accentSoft = Color(0xFFFBF3DD);
  static const Color accentInk = Color(0xFF6E551A);

  // =========================
  // BACKGROUND
  // =========================

  static const Color background = Color(0xFFF4F6FB);

  // =========================
  // SURFACE
  // =========================

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF1F4FB);

  // =========================
  // TEXT / INK
  // =========================

  static const Color ink = Color(0xFF0E1525);
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

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // =========================
  // GRADIENTS
  // =========================

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
}
