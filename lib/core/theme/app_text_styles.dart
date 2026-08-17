import 'package:flutter/material.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const String fontBody = 'Inter'; // NEW
  static const String fontDisplay = 'CormorantGaramond'; // NEW

  /// Brand logo — "TheVaults"  (NEW, spec §1)
  static const TextStyle brandLogo = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 34,
    fontWeight: FontWeight.w500,
    height: 1.1,
  );

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontBody, // CHANGED: Roboto → Inter
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontBody, // CHANGED
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily:
        fontBody, // CHANGED: CormorantGaramond → Inter (logo ke liye brandLogo use karo)
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );
}
