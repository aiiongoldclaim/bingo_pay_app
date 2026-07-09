import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppSnackbar {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void showSuccessWithAction(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor ?? AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2500),
          // SnackBar defaults `persist` to true whenever an action is set,
          // which disables the auto-dismiss timer entirely. Force it off so
          // this still hides on its own if the action is never tapped.
          persist: false,
          action: SnackBarAction(
            label: actionLabel,
            textColor: Colors.white,
            onPressed: onAction,
          ),
        ),
      );
  }
}
