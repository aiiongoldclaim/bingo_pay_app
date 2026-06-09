import 'package:bingo_pay/core/api/interceptors/error_interceptor.dart';
import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class FakeDioException extends Fake implements DioException {}

void main() {
  late ErrorInterceptor interceptor;
  late MockErrorInterceptorHandler handler;

  setUpAll(() {
    registerFallbackValue(FakeDioException());
  });

  setUp(() {
    interceptor = ErrorInterceptor();
    handler = MockErrorInterceptorHandler();
  });

  group('ErrorInterceptor', () {
    test('rejects with ServerException on 500 response', () {
      when(() => handler.reject(any())).thenReturn(null);

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
          data: {'message': 'Internal server error'},
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(dioError, handler);

      final captured = verify(() => handler.reject(captureAny())).captured;
      expect(
        (captured.first as DioException).error,
        isA<ServerException>(),
      );
    });

    test('rejects with NetworkException on connection error', () {
      when(() => handler.reject(any())).thenReturn(null);

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      interceptor.onError(dioError, handler);

      final captured = verify(() => handler.reject(captureAny())).captured;
      expect(
        (captured.first as DioException).error,
        isA<NetworkException>(),
      );
    });
  });
}
