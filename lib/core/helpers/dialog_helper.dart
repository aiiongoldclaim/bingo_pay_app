import 'package:flutter/material.dart';

class DialogHelper {
  DialogHelper._();

  /// Shows a success dialog with a title, message, and action button
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String actionLabel = 'OK',
    VoidCallback? onAction,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onAction?.call();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  /// Shows an error dialog with a title, message, and close button
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String actionLabel = 'Close',
    VoidCallback? onAction,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 64),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onAction?.call();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog with yes/no options
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Yes',
    String cancelLabel = 'No',
    bool barrierDismissible = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.help, color: Colors.blue, size: 64),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  /// Shows an info dialog with a title, message, and action button
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String actionLabel = 'OK',
    VoidCallback? onAction,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.info, color: Colors.blue, size: 64),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onAction?.call();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  /// Shows a custom dialog with full control over the content
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = false,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: builder,
    );
  }
}
