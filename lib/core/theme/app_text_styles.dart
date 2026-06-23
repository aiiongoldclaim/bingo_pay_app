import 'package:flutter/material.dart';
import 'theme_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  /// Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: ThemeColors.ink,
    fontFamily: 'CormorantGaramond',
    letterSpacing: -0.5,
  );

  /// Headings
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFamily: 'CormorantGaramond',
    color: ThemeColors.ink,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'CormorantGaramond',
    color: ThemeColors.black,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'CormorantGaramond',
    color: ThemeColors.ink,
  );

  /// Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: 'CormorantGaramond',
    color: ThemeColors.ink,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ThemeColors.inkMid,
    fontFamily: 'CormorantGaramond',
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'CormorantGaramond',
    color: ThemeColors.inkDim,
    height: 1.4,
  );

  /// Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'CormorantGaramond',
    color: ThemeColors.ink,
    letterSpacing: 0.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: 'CormorantGaramond',
    color: ThemeColors.inkMid,
    letterSpacing: 0.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: ThemeColors.inkDim,
    fontFamily: 'CormorantGaramond',
    letterSpacing: 0.5,
  );

  /// Buttons
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'CormorantGaramond',
    letterSpacing: 0.2,
    color: ThemeColors.white,
  );

  /// Gold Banner Styles
  static const TextStyle bannerTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'CormorantGaramond',
    letterSpacing: 2,
    color: ThemeColors.accentInk,
  );

  static const TextStyle bannerHeading = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w600,
    fontFamily: 'CormorantGaramond',
    height: 0.95,
    color: ThemeColors.accentInk,
  );
}
