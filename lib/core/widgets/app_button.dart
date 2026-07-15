import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outlined }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
  });

  Widget _spinner(Color color) => SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: color),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveOnPressed = isLoading ? null : onPressed;

    // Shared metrics so every variant matches the elevated button theme.
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
    );
    const minSize = Size(double.infinity, AppDimensions.buttonHeight);

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: isLoading
            ? ElevatedButton.styleFrom(
                disabledBackgroundColor: AppColors.primary,
                disabledForegroundColor: Colors.white,
              )
            : null,
        child: isLoading ? _spinner(Colors.white) : Text(label),
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          minimumSize: minSize,
          shape: shape,
          textStyle: AppTextStyles.buttonText,
          disabledBackgroundColor: isLoading ? scheme.secondaryContainer : null,
          disabledForegroundColor: isLoading
              ? scheme.onSecondaryContainer
              : null,
        ),
        child: isLoading ? _spinner(scheme.onSecondaryContainer) : Text(label),
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: minSize,
          shape: shape,
          textStyle: AppTextStyles.buttonText,
          foregroundColor: AppColors.primary,
          side: isLoading || onPressed != null
              ? const BorderSide(color: AppColors.primary)
              : null,
          disabledForegroundColor: isLoading ? AppColors.primary : null,
        ),
        child: isLoading ? _spinner(AppColors.primary) : Text(label),
      ),
    };
  }
}
