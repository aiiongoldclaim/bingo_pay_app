import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  const ErrorHandler._();

  static Failure mapExceptionToFailure(Exception exception) {
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
