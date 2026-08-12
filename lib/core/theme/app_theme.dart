import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_dimensions.dart';
import 'app_text_styles.dart';
import 'app_theme_colors.dart';
import 'theme_colors.dart';

// class AppTheme {
//   static ThemeData get light => _buildTheme(Brightness.light);
//   static ThemeData get dark => _buildTheme(Brightness.dark);
//
//   static ThemeData _buildTheme(Brightness brightness) {
//     final isLight = brightness == Brightness.light;
//
//     final colorScheme = ColorScheme(
//       brightness: brightness,
//       primary: ThemeColors.primaryPurple,
//       onPrimary: ThemeColors.white,
//       secondary: ThemeColors.lavender, // CHANGED: accent → lavender
//       onSecondary: ThemeColors.white,
//       error: ThemeColors.red,
//       onError: ThemeColors.white,
//       surface: isLight
//           ? ThemeColors.surface
//           : ThemeColors.darkSurface, // CHANGED
//       onSurface: isLight
//           ? ThemeColors.textPrimary
//           : ThemeColors.darkTextPrimary,
//     );
//
//     return ThemeData(
//       useMaterial3: true,
//       fontFamily: 'Inter', // CHANGED: Roboto → Inter (spec §1)
//       colorScheme: colorScheme,
//
//       scaffoldBackgroundColor: isLight
//           ? ThemeColors.background
//           : ThemeColors.darkBackground, // CHANGED
//
//       dividerColor: isLight ? ThemeColors.border : ThemeColors.darkBorder,
//
//       // NEW: ThemeExtension so screens never hardcode colors
//       extensions: <ThemeExtension<dynamic>>[
//         isLight ? AppThemeColors.lightColors : AppThemeColors.darkColors,
//       ],
//
//       textTheme: TextTheme(
//         displayLarge: AppTextStyles.displayLarge,
//         headlineMedium: AppTextStyles.headlineMedium,
//         titleLarge: AppTextStyles.titleLarge,
//         bodyLarge: AppTextStyles.bodyLarge,
//         bodyMedium: AppTextStyles.bodyMedium,
//         labelMedium: AppTextStyles.labelMedium,
//       ),
//
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor:
//               ThemeColors.primaryPurple, // CHANGED: blue → primaryPurple
//           foregroundColor: ThemeColors.white,
//           minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
//           ),
//           textStyle: AppTextStyles.buttonText,
//         ),
//       ),
//
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: isLight ? ThemeColors.surface : ThemeColors.darkSurface,
//         border: _border(isLight),
//         enabledBorder: _border(isLight),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
//           borderSide: const BorderSide(
//             color: ThemeColors.primaryPurple, // CHANGED: blue → primaryPurple
//             width: 1.5,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
//           borderSide: const BorderSide(color: ThemeColors.red),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: AppDimensions.md,
//           vertical: AppDimensions.md,
//         ),
//       ),
//
//       appBarTheme: AppBarTheme(
//         backgroundColor: isLight
//             ? ThemeColors.background
//             : ThemeColors.darkBackground,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         centerTitle: true,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
//           statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
//           systemNavigationBarColor: isLight
//               ? ThemeColors.background
//               : ThemeColors.darkBackground,
//           systemNavigationBarIconBrightness: isLight
//               ? Brightness.dark
//               : Brightness.light,
//         ),
//         titleTextStyle: AppTextStyles.titleLarge.copyWith(
//           color: isLight
//               ? ThemeColors.textPrimary
//               : ThemeColors.darkTextPrimary,
//         ),
//         iconTheme: IconThemeData(
//           color: isLight
//               ? ThemeColors.textPrimary
//               : ThemeColors.darkTextPrimary,
//         ),
//       ),
//     );
//   }
//
//   static OutlineInputBorder _border(bool isLight) => OutlineInputBorder(
//     borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
//     borderSide: BorderSide(
//       color: isLight ? ThemeColors.border : ThemeColors.darkBorder,
//     ),
//   );
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_dimensions.dart';
import 'app_text_styles.dart';
import 'app_theme_colors.dart';
import 'theme_colors.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final c = isLight ? AppThemeColors.lightColors : AppThemeColors.darkColors;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.brand, // CHANGED
      onPrimary: ThemeColors.white,
      secondary: ThemeColors.lavender,
      onSecondary: ThemeColors.white,
      error: ThemeColors.red,
      onError: ThemeColors.white,
      surface: c.surface, // CHANGED
      onSurface: c.textPrimary, // CHANGED
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontBody, // CHANGED: Roboto → Inter
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      dividerColor: c.border,

      extensions: <ThemeExtension<dynamic>>[c], // NEW

      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: c.textPrimary),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: c.textPrimary,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: c.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: c.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: c.textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.brand, // CHANGED: blue → brand
          foregroundColor: ThemeColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        border: _border(c.border),
        enabledBorder: _border(c.border),
        focusedBorder: _border(c.brand, width: 1.5),
        errorBorder: _border(ThemeColors.red),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
          statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: c.background,
          systemNavigationBarIconBrightness: isLight
              ? Brightness.dark
              : Brightness.light,
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: c.textPrimary),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: color, width: width),
      );
}
