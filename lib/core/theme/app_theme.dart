import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_glass.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final semantic = isLight ? AppSemanticColors.light : AppSemanticColors.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [
        semantic,
        isLight ? AppGlassColors.light : AppGlassColors.dark,
      ],
      scaffoldBackgroundColor: semantic.background,
      cardColor: semantic.card,
      dividerColor: semantic.border,
      textTheme: TextTheme(
        displayLarge:
            AppTextStyles.displayLarge.copyWith(color: semantic.textPrimary),
        headlineMedium:
            AppTextStyles.headlineMedium.copyWith(color: semantic.textPrimary),
        titleLarge:
            AppTextStyles.titleLarge.copyWith(color: semantic.textPrimary),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: semantic.textPrimary),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: semantic.textPrimary),
        labelMedium:
            AppTextStyles.labelMedium.copyWith(color: semantic.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantic.inputFill,
        hintStyle: TextStyle(color: semantic.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: semantic.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: semantic.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: semantic.card,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTextStyles.titleLarge.copyWith(color: semantic.textPrimary),
        iconTheme: IconThemeData(color: semantic.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: semantic.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: semantic.textSecondary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: semantic.card,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
