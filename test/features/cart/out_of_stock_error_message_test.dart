import 'package:bingo_pay/core/api/interceptors/error_interceptor.dart';
import 'package:bingo_pay/core/error/error_handler.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';


class _RecordingHandler extends ErrorInterceptorHandler {
  DioException? rejected;

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    rejected = err;
  }
}

void main() {
  test(
    'a server-side out-of-stock rejection (422 with a specific message) '
    'surfaces that exact message end-to-end, not a generic fallback',
    () {
      final interceptor = ErrorInterceptor();
      final handler = _RecordingHandler();

      final requestOptions = RequestOptions(path: '/api/v1/cart/items');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 422,
          data: {
            'success': false,
            'statusCode': 422,
            'message': 'This item just went out of stock',
            'errors': {},
          },
        ),
      );

      interceptor.onError(dioError, handler);

      final wrapped = handler.rejected;
      expect(wrapped, isNotNull);
      final innerException = wrapped!.error;
      expect(innerException, isA<Exception>());

      final failure = ErrorHandler.mapExceptionToFailure(innerException as Exception);
      expect(failure, isA<ValidationFailure>());
      expect(
        failure.message,
        'This item just went out of stock',
        reason: "the server's own specific message must survive intact — "
            'CartCubit.addItem() forwards failure.message as '
            'result.errorMessage, and product_details_screen.dart shows it '
            'directly via AppSnackbar.showError(context, result.errorMessage '
            "?? 'Something went wrong...') — since errorMessage is non-null "
            'here, the specific message is what the user actually sees, not '
            'the generic fallback',
      );
    },
  );

  test(
    'if the backend omits a message on a 422, the client falls back to a '
    'generic (but not nonsensical) message rather than crashing',
    () {
      final interceptor = ErrorInterceptor();
      final handler = _RecordingHandler();

      final requestOptions = RequestOptions(path: '/api/v1/cart/items');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 422,
          data: {'success': false, 'statusCode': 422},
        ),
      );

      interceptor.onError(dioError, handler);

      final innerException = handler.rejected!.error as Exception;
      final failure = ErrorHandler.mapExceptionToFailure(innerException);
      expect(failure, isA<ValidationFailure>());
      // error_interceptor.dart's _getDefaultMessage() has no specific case
      // for 422 — it falls through to the generic catch-all. Not wrong,
      // but not specifically actionable either.
      expect(failure.message, 'An error occurred. Please try again.');
    },
  );
}
