import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'glass/glass_card.dart';

/// Floating, auto-dismissing toast shown near the top of the screen.
///
/// Drop-in replacement for [SnackBar]: same `AppSnackbar.showError` /
/// `showSuccess` call sites, but rendered via the `toastification` package
/// as a top overlay so it never gets hidden behind bottom nav bars, FABs,
/// or keyboard-docked buttons.
class AppSnackbar {
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
      tint: AppColors.errorTint,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.success,
      tint: AppColors.successTint,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    required Color tint,
  }) {
    toastification.showCustom(
      context: context,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      builder: (context, item) => _ToastCard(
        message: message,
        icon: icon,
        color: color,
        tint: tint,
        onDismiss: () => toastification.dismiss(item),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback onDismiss;

  const _ToastCard({
    required this.message,
    required this.icon,
    required this.color,
    required this.tint,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppDimensions.sm,
        left: AppDimensions.md,
        right: AppDimensions.md,
      ),
      child: GestureDetector(
        onTap: onDismiss,
        onVerticalDragEnd: (_) => onDismiss(),
        child: GlassCard(
          tint: tint,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm + 4,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
