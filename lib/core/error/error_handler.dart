import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  const ErrorHandler._();

  static Failure mapExceptionToFailure(Exception exception) {
    // ErrorInterceptor wraps the typed exception inside DioException.error;
    // unwrap it so the real failure (and message) is preserved instead of
    // falling through to UnknownFailure.
    if (exception is DioException && exception.error is Exception) {
      return mapExceptionToFailure(exception.error as Exception);
    }
    return switch (exception) {
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
      _ => UnknownFailure(exception.toString()),
    };
  }
}
