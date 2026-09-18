import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../services/in_app_review_service.dart';

part 'in_app_review_state.dart';

@singleton
class InAppReviewCubit extends Cubit<InAppReviewState> {
  final InAppReviewService _reviewService;

  InAppReviewCubit(this._reviewService)
      : super(const InAppReviewState.initial());

  /// Request in-app review from Play Store / App Store
  Future<void> requestReview() async {
    emit(const InAppReviewState.loading());

    try {
      final success = await _reviewService.requestReview();
      if (success) {
        emit(const InAppReviewState.reviewRequested());
      } else {
        emit(const InAppReviewState.reviewNotAvailable());
      }
    } catch (e) {
      emit(InAppReviewState.error('Failed to request review: $e'));
    }
  }

  /// Fallback: Open app store page for review
  Future<void> openAppStore() async {
    emit(const InAppReviewState.loading());

    try {
      final success = await _reviewService.openAppStoreReview();
      if (success) {
        emit(const InAppReviewState.appStoreOpened());
      } else {
        emit(const InAppReviewState.error('Could not open app store'));
      }
    } catch (e) {
      emit(InAppReviewState.error('Failed to open app store: $e'));
    }
  }

  /// Reset state
  void reset() {
    emit(const InAppReviewState.initial());
  }
}
