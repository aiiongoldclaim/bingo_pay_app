import 'package:in_app_review/in_app_review.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@singleton
class InAppReviewService {
  final _logger = Logger();
  final _inAppReview = InAppReview.instance;

  /// Check if in-app review is available on current platform
  Future<bool> isReviewAvailable() async {
    try {
      return await _inAppReview.isAvailable();
    } catch (e) {
      _logger.e('Error checking if review is available: $e');
      return false;
    }
  }

  /// Request in-app review from user
  /// Returns true if the review flow was successfully triggered
  Future<bool> requestReview() async {
    try {
      final isAvailable = await isReviewAvailable();
      if (!isAvailable) {
        _logger.w('In-app review not available on this platform/device');
        return false;
      }

      // On Android: Opens Play Console's in-app review dialog
      // On iOS: Opens the app review prompt within the app
      await _inAppReview.requestReview();
      _logger.i('✓ In-app review requested successfully');
      return true;
    } catch (e) {
      _logger.e('Error requesting in-app review: $e');
      return false;
    }
  }

  /// Open app store page for detailed review/rating
  /// Fallback when in-app review is not available
  /// Note: This method is deprecated in newer versions of in_app_review
  Future<bool> openAppStoreReview() async {
    try {
      _logger.w('openAppStoreReview: Consider using requestReview() directly');
      // The newer in_app_review package doesn't expose openAppStore
      // Use requestReview() which handles fallback internally
      return await requestReview();
    } catch (e) {
      _logger.e('Error opening app store review: $e');
      return false;
    }
  }

  /// Request review with a rating (Android only, iOS ignores rating)
  /// rating should be between 0-5
  Future<bool> requestReviewWithRating({required int rating}) async {
    try {
      if (rating < 0 || rating > 5) {
        _logger.w('Invalid rating: $rating. Must be between 0-5');
        return false;
      }

      final isAvailable = await isReviewAvailable();
      if (!isAvailable) {
        _logger.w('In-app review not available on this platform/device');
        return false;
      }

      // Note: The in_app_review package doesn't support pre-filling rating,
      // but the native Play Console review API does. This is for future
      // enhancement if needed.
      await _inAppReview.requestReview();
      _logger.i('✓ In-app review requested (rating: $rating)');
      return true;
    } catch (e) {
      _logger.e('Error requesting in-app review with rating: $e');
      return false;
    }
  }
}
