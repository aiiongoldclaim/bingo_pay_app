import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/in_app_review_cubit.dart';
import '../widgets/review_dialog.dart';
import '../widgets/review_bottom_sheet.dart';

/// Helper class to easily trigger in-app reviews from anywhere in the app
class ReviewHelper {
  /// Show review dialog
  /// Trigger this after successful purchase, order, or any positive user action
  static void showReviewDialog(
    BuildContext context, {
    String title = 'Rate This App',
    String subtitle =
        'Help us improve by sharing your feedback and rating this app',
    String positiveRatingMessage =
        'Thanks for rating us! Help us improve by sharing your review.',
    String negativeRatingMessage = 'We appreciate your feedback!',
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ReviewDialog(
        title: title,
        subtitle: subtitle,
        positiveRatingMessage: positiveRatingMessage,
        negativeRatingMessage: negativeRatingMessage,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Show review bottom sheet
  /// Alternative to dialog, often better UX on mobile
  static void showReviewBottomSheet(
    BuildContext context, {
    String title = 'Rate This App',
    String subtitle =
        'Help us improve by sharing your feedback and rating this app',
    String positiveRatingMessage =
        'Thanks for rating us! Help us improve by sharing your review.',
    String negativeRatingMessage = 'We appreciate your feedback!',
    VoidCallback? onDismiss,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => ReviewBottomSheet(
        title: title,
        subtitle: subtitle,
        positiveRatingMessage: positiveRatingMessage,
        negativeRatingMessage: negativeRatingMessage,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Manually request review from Play Store / App Store (without UI)
  /// Returns true if review was successfully requested
  static Future<bool> requestReviewDirect(BuildContext context) async {
    try {
      final cubit = context.read<InAppReviewCubit>();
      cubit.requestReview();
      return true;
    } catch (e) {
      debugPrint('Error requesting review: $e');
      return false;
    }
  }
}

/// Extension on BuildContext for easier access
extension ReviewContextExtension on BuildContext {
  void showReviewDialog({
    String title = 'Rate This App',
    String subtitle =
        'Help us improve by sharing your feedback and rating this app',
    VoidCallback? onDismiss,
  }) =>
      ReviewHelper.showReviewDialog(
        this,
        title: title,
        subtitle: subtitle,
        onDismiss: onDismiss,
      );

  void showReviewBottomSheet({
    String title = 'Rate This App',
    String subtitle =
        'Help us improve by sharing your feedback and rating this app',
    VoidCallback? onDismiss,
  }) =>
      ReviewHelper.showReviewBottomSheet(
        this,
        title: title,
        subtitle: subtitle,
        onDismiss: onDismiss,
      );
}
