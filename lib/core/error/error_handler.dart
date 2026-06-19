import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  const ErrorHandler._();

  /// Maps any error thrown by a data source into a [Failure].
  ///
  /// Accepts [Object] rather than [Exception] because [DioException] wraps
  /// the real mapped exception in its `error` field, and JSON parsing
  /// mistakes (bad casts, missing keys) throw [Error]s, not [Exception]s —
  /// both must be normalized into a [Failure] so the UI always gets a state
  /// it can render instead of leaving callers stuck mid-request.
  static Failure mapErrorToFailure(Object error) {
    final resolved =
        error is DioException && error.error != null ? error.error! : error;
    return switch (resolved) {
      ServerException e => ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          serverMessage: e.message,
        ),
      NetworkException _ => const NetworkFailure(),
      AuthException e => AuthFailure(message: e.message),
      ValidationException e => ValidationFailure(
          message: e.message,
          fieldErrors: e.fieldErrors,
        ),
      CacheException e => CacheFailure(message: e.message),
      _ => UnknownFailure(resolved.toString()),
    };
  }
}
