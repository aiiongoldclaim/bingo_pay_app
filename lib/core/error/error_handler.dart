import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  const ErrorHandler._();

  static Failure mapExceptionToFailure(Exception exception) {
    // ErrorInterceptor may wrap the typed exception inside
    // DioException.error. Unwrap it so the original exception
    // can be mapped correctly.
    if (exception is DioException && exception.error is Exception) {
      return mapExceptionToFailure(
        exception.error as Exception,
      );
    }

    return switch (exception) {
      ServerException e => ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          serverMessage: e.message,
        ),

      NetworkException _ => const NetworkFailure(),

      AuthException e => AuthFailure(
          message: e.message,
        ),

      EmailNotVerifiedException e => EmailNotVerifiedFailure(
          message: e.message,
        ),

      ValidationException e => ValidationFailure(
          message: e.message,
          fieldErrors: e.fieldErrors,
        ),

      RateLimitException e => RateLimitFailure(
          message: e.message,
          retryAfterSeconds: e.retryAfterSeconds,
        ),

      CacheException e => CacheFailure(
          message: e.message,
        ),

      _ => UnknownFailure(
          exception.toString(),
        ),
    };
  }

  /// Handles both Exception and Error objects safely.
  ///
  /// Repository boundaries use this method so that both normal
  /// Exceptions and Dart Errors such as TypeError are converted
  /// into a Failure.
  static Failure mapObjectToFailure(Object error) {
    if (error is DioException && error.error != null) {
      return mapObjectToFailure(
        error.error!,
      );
    }

    if (error is Exception) {
      return mapExceptionToFailure(error);
    }

    return UnknownFailure(
      error.toString(),
    );
  }
}