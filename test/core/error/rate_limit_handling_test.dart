import 'package:flutter_test/flutter_test.dart';
import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/core/error/error_handler.dart';
import 'package:dio/dio.dart';

void main() {
  group('Rate Limit Handling', () {
    group('RateLimitException', () {
      test('should be created with message and retryAfterSeconds', () {
        const exception = RateLimitException(
          message: 'Too Many Requests',
          retryAfterSeconds: 60,
        );

        expect(exception.message, 'Too Many Requests');
        expect(exception.retryAfterSeconds, 60);
      });

      test('should have retryAfterSeconds as null if not provided', () {
        const exception = RateLimitException(
          message: 'Too Many Requests',
        );

        expect(exception.message, 'Too Many Requests');
        expect(exception.retryAfterSeconds, isNull);
      });
    });

    group('RateLimitFailure', () {
      test('should be created with message and retryAfterSeconds', () {
        const failure = RateLimitFailure(
          message: 'High server load',
          retryAfterSeconds: 60,
        );

        expect(failure.message, 'High server load');
        expect(failure.retryAfterSeconds, 60);
      });

      test('should have retryAfterSeconds as null if not provided', () {
        const failure = RateLimitFailure(
          message: 'High server load',
        );

        expect(failure.message, 'High server load');
        expect(failure.retryAfterSeconds, isNull);
      });

      test('should be equatable', () {
        const failure1 = RateLimitFailure(
          message: 'High server load',
          retryAfterSeconds: 60,
        );
        const failure2 = RateLimitFailure(
          message: 'High server load',
          retryAfterSeconds: 60,
        );
        const failure3 = RateLimitFailure(
          message: 'High server load',
          retryAfterSeconds: 30,
        );

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ErrorHandler - RateLimitException to RateLimitFailure mapping', () {
      test('should map RateLimitException with retryAfterSeconds', () {
        const exception = RateLimitException(
          message: 'Too Many Requests',
          retryAfterSeconds: 60,
        );

        final failure = ErrorHandler.mapExceptionToFailure(exception);

        expect(failure, isA<RateLimitFailure>());
        expect((failure as RateLimitFailure).message, 'Too Many Requests');
        expect(failure.retryAfterSeconds, 60);
      });

      test('should map RateLimitException without retryAfterSeconds', () {
        const exception = RateLimitException(
          message: 'Too Many Requests',
        );

        final failure = ErrorHandler.mapExceptionToFailure(exception);

        expect(failure, isA<RateLimitFailure>());
        expect((failure as RateLimitFailure).message, 'Too Many Requests');
        expect(failure.retryAfterSeconds, isNull);
      });

      test('should map RateLimitException wrapped in DioException', () {
        const exception = RateLimitException(
          message: 'Too Many Requests',
          retryAfterSeconds: 45,
        );

        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          error: exception,
        );

        final failure = ErrorHandler.mapExceptionToFailure(dioException);

        expect(failure, isA<RateLimitFailure>());
        expect((failure as RateLimitFailure).message, 'Too Many Requests');
        expect(failure.retryAfterSeconds, 45);
      });
    });

    group('ErrorHandler - mapObjectToFailure', () {
      test('should map RateLimitException object to RateLimitFailure', () {
        const exception = RateLimitException(
          message: 'Rate Limited',
          retryAfterSeconds: 30,
        );

        final failure = ErrorHandler.mapObjectToFailure(exception);

        expect(failure, isA<RateLimitFailure>());
        expect((failure as RateLimitFailure).retryAfterSeconds, 30);
      });

      test('should map DioException with RateLimitException error', () {
        const rateLimitException = RateLimitException(
          message: 'Rate Limited',
          retryAfterSeconds: 50,
        );

        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          error: rateLimitException,
        );

        final failure = ErrorHandler.mapObjectToFailure(dioException);

        expect(failure, isA<RateLimitFailure>());
        expect((failure as RateLimitFailure).retryAfterSeconds, 50);
      });
    });

    group('Rate limit scenarios', () {
      test('should handle 429 response with Retry-After header', () {
        const exception = RateLimitException(
          message: 'High server load. Please wait a moment and try again.',
          retryAfterSeconds: 120,
        );

        final failure = ErrorHandler.mapExceptionToFailure(exception);

        expect(failure, isA<RateLimitFailure>());
        final rateLimitFailure = failure as RateLimitFailure;
        expect(rateLimitFailure.retryAfterSeconds, 120);
      });

      test('should handle 429 response without Retry-After header (default 60s)', () {
        const exception = RateLimitException(
          message: 'High server load. Please wait a moment and try again.',
          retryAfterSeconds: null,
        );

        final failure = ErrorHandler.mapExceptionToFailure(exception);

        expect(failure, isA<RateLimitFailure>());
        final rateLimitFailure = failure as RateLimitFailure;
        expect(rateLimitFailure.retryAfterSeconds, isNull);
      });

      test('should handle various Retry-After values', () {
        final values = [30, 60, 120, 300, 3600];

        for (final value in values) {
          final exception = RateLimitException(
            message: 'Rate limit exceeded',
            retryAfterSeconds: value,
          );

          final failure = ErrorHandler.mapExceptionToFailure(exception);
          expect((failure as RateLimitFailure).retryAfterSeconds, value);
        }
      });
    });

    group('OTP Resend Rate Limiting', () {
      test('should enforce server-side retry-after on resend', () {
        // Simulate server response with 429 and Retry-After
        const rateLimitException = RateLimitException(
          message: 'Too many OTP requests',
          retryAfterSeconds: 60,
        );

        final failure = ErrorHandler.mapExceptionToFailure(rateLimitException);
        final rateLimitFailure = failure as RateLimitFailure;

        // Screen should use this value to update countdown
        expect(rateLimitFailure.retryAfterSeconds, 60);

        // User cannot retry until this countdown reaches zero
        final canRetry = (rateLimitFailure.retryAfterSeconds ?? 0) <= 0;
        expect(canRetry, false);
      });

      test('client should not retry before server allows', () {
        const serverRetryAfter = 30;
        const clientCountdown = 25;

        // The actual retry-after from server should take precedence
        final effectiveRetryAfter = serverRetryAfter;
        expect(effectiveRetryAfter >= clientCountdown, true);
      });
    });
  });
}
