part of 'in_app_review_cubit.dart';

sealed class InAppReviewState {
  const InAppReviewState();

  const factory InAppReviewState.initial() = InitialState;
  const factory InAppReviewState.loading() = LoadingState;
  const factory InAppReviewState.reviewRequested() = ReviewRequestedState;
  const factory InAppReviewState.reviewNotAvailable() = ReviewNotAvailableState;
  const factory InAppReviewState.appStoreOpened() = AppStoreOpenedState;
  const factory InAppReviewState.error(String message) = ErrorState;

  bool get isLoading => this is LoadingState;
  bool get isReviewRequested => this is ReviewRequestedState;
  bool get isError => this is ErrorState;
  String? get errorMessage => this is ErrorState ? (this as ErrorState).message : null;
}

class InitialState extends InAppReviewState {
  const InitialState();
}

class LoadingState extends InAppReviewState {
  const LoadingState();
}

class ReviewRequestedState extends InAppReviewState {
  const ReviewRequestedState();
}

class ReviewNotAvailableState extends InAppReviewState {
  const ReviewNotAvailableState();
}

class AppStoreOpenedState extends InAppReviewState {
  const AppStoreOpenedState();
}

class ErrorState extends InAppReviewState {
  final String message;
  const ErrorState(this.message);
}
