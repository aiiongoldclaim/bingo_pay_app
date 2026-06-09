import 'package:bingo_pay/core/error/error_handler.dart';
import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorHandler.mapExceptionToFailure', () {
    test('maps ServerException to ServerFailure', () {
      final exception = const ServerException(
        statusCode: 500,
        message: 'Internal server error',
      );
      final failure = ErrorHandler.mapExceptionToFailure(exception);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('maps NetworkException to NetworkFailure', () {
      const exception = NetworkException();
      final failure = ErrorHandler.mapExceptionToFailure(exception);
      expect(failure, isA<NetworkFailure>());
    });

    test('maps AuthException to AuthFailure', () {
      const exception = AuthException(message: 'Unauthorized');
      final failure = ErrorHandler.mapExceptionToFailure(exception);
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Unauthorized');
    });

    test('maps ValidationException to ValidationFailure with field errors', () {
      const exception = ValidationException(
        message: 'Validation failed',
        fieldErrors: {'email': 'Already in use'},
      );
      final failure = ErrorHandler.mapExceptionToFailure(exception);
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors['email'], 'Already in use');
    });

    test('maps unknown Exception to UnknownFailure', () {
      final exception = Exception('Something unexpected');
      final failure = ErrorHandler.mapExceptionToFailure(exception);
      expect(failure, isA<UnknownFailure>());
    });
  });
}
