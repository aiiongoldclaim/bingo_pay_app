// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'app_dimensions.dart';
// import 'app_text_styles.dart';
// import 'app_theme_colors.dart';
// import 'theme_colors.dart';
//
// class AppTheme {
//   static ThemeData get light => _buildTheme(Brightness.light);
//   static ThemeData get dark => _buildTheme(Brightness.dark);
//
//   static ThemeData _buildTheme(Brightness brightness) {
//     final isLight = brightness == Brightness.light;
//     final colors = isLight ? AppThemeColors.lightColors : AppThemeColors.darkColors;
//
//     final colorScheme = ColorScheme(
//       brightness: brightness,
//       primary: colors.brand, // CHANGED
//       onPrimary: ThemeColors.white,
//       secondary: ThemeColors.lavender,
//       onSecondary: ThemeColors.white,
//       error: ThemeColors.red,
//       onError: ThemeColors.white,
//       surface: colors.surface, // CHANGED
//       onSurface: colors.textPrimary, // CHANGED
//     );
//
//     return ThemeData(
//       useMaterial3: true,
//       fontFamily: AppTextStyles.fontBody, // CHANGED: Roboto → Inter
//       colorScheme: colorScheme,
//       scaffoldBackgroundColor: colors.background,
//       dividerColor: colors.border,
//
//       extensions: <ThemeExtension<dynamic>>[colors], // NEW
//
//       textTheme: TextTheme(
//         displayLarge: AppTextStyles.displayLarge.copyWith(color: colors.textPrimary),
//         headlineMedium: AppTextStyles.headlineMedium.copyWith(
//           color: colors.textPrimary,
//         ),
//         titleLarge: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
//         bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
//         bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
//         labelMedium: AppTextStyles.labelMedium.copyWith(color: colors.textSecondary),
//       ),
//
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: colors.brand, // CHANGED: blue → brand
//           foregroundColor: ThemeColors.white,
//           elevation: 0,
//           minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
//           ),
//           textStyle: AppTextStyles.buttonText,
//         ),
//       ),
//
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: colors.surface,
//         border: _border(colors.border),
//         enabledBorder: _border(colors.border),
//         focusedBorder: _border(colors.brand, width: 1.5),
//         errorBorder: _border(ThemeColors.red),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: AppDimensions.md,
//           vertical: AppDimensions.md,
//         ),
//       ),
//
//       appBarTheme: AppBarTheme(
//         backgroundColor: colors.background,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         centerTitle: true,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
//           statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
//           systemNavigationBarColor: colors.background,
//           systemNavigationBarIconBrightness: isLight
//               ? Brightness.dark
//               : Brightness.light,
//         ),
//         titleTextStyle: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
//         iconTheme: IconThemeData(color: colors.textPrimary),
//       ),
//     );
//   }
//
//   static OutlineInputBorder _border(Color color, {double width = 1}) =>
//       OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
//         borderSide: BorderSide(color: color, width: width),
//       );
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_dimensions.dart';
import 'app_text_styles.dart';
import 'app_theme_colors.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final colors =
    isLight ? AppThemeColors.lightColors : AppThemeColors.darkColors;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.brand,
      brightness: brightness,
    ).copyWith(
      primary: colors.brand,
      onPrimary: colors.onBrand,
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      error: colors.error,
      onError: colors.onError,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      outline: colors.border,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontBody,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.border,

      extensions: <ThemeExtension<dynamic>>[colors],

      textTheme: TextTheme(
        displayLarge:
        AppTextStyles.displayLarge.copyWith(color: colors.textPrimary),
        headlineMedium:
        AppTextStyles.headlineMedium.copyWith(color: colors.textPrimary),
        titleLarge:
        AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
        bodyMedium:
        AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        labelMedium:
        AppTextStyles.labelMedium.copyWith(color: colors.textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.brand,
          foregroundColor: colors.onBrand,
          disabledBackgroundColor: colors.buttonDisabledFill,
          disabledForegroundColor: colors.textDisabled,
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
        fillColor: colors.surface,
        border: _border(colors.border),
        enabledBorder: _border(colors.border),
        focusedBorder: _border(colors.brand, width: 1.5),
        errorBorder: _border(colors.error),
        focusedErrorBorder: _border(colors.error, width: 1.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
          statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: colors.background,
          systemNavigationBarIconBrightness:
          isLight ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle:
        AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
    );
  }

  static OutlineInputBorder _border(Color borderColor, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: borderColor, width: width),
      );
}