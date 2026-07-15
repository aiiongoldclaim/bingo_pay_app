import 'error_handler.dart';
import 'failures.dart';

const _fallbackMessage = 'Something went wrong. Please try again.';

/// Converts any raw error (DioException, mapped exceptions, Failures) into
/// a human-readable message safe to show in the UI. Never returns raw
/// exception text or JSON.
String friendlyErrorMessage(Object? error) {
  if (error == null) return _fallbackMessage;
  final failure =
      error is Failure ? error : ErrorHandler.mapErrorToFailure(error);
  return switch (failure) {
    NetworkFailure _ =>
      'No internet connection. Please check your network and try again.',
    ServerFailure f when (f.statusCode ?? 500) >= 500 ||
            f.message.trim().isEmpty ||
            f.message == 'Server error' =>
      'Server error. Please try again later.',
    ServerFailure f => f.message,
    AuthFailure _ => 'Your session has expired. Please log in again.',
    ValidationFailure f when f.message.trim().isNotEmpty => f.message,
    _ => _fallbackMessage,
  };
}
