import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  Exception _mapDioError(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }

    final response = err.response;
    if (response == null) return const NetworkException();

    final message = _extractMessage(response.data) ?? _getDefaultMessage(response.statusCode);
    final fieldErrors = _extractFieldErrors(response.data);

    return switch (response.statusCode) {
      401 => AuthException(message: message),
      422 => ValidationException(message: message, fieldErrors: fieldErrors),
      429 => RateLimitException(
          message: message,
          retryAfterSeconds: _extractRetryAfter(response),
        ),
      _ => ServerException(statusCode: response.statusCode, message: message),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String?;
      if (message != null && message.isNotEmpty) return message;
    }
    return null;
  }

  Map<String, String> _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return Map<String, String>.from(data['errors'] as Map);
    }
    return {};
  }

  int? _extractRetryAfter(Response response) {
    final retryAfter = response.headers.value('retry-after');
    if (retryAfter != null) {
      return int.tryParse(retryAfter);
    }
    return null;
  }

  String _getDefaultMessage(int? statusCode) {
    return switch (statusCode) {
      400 => 'Invalid request. Please check your input.',
      401 => 'Unauthorized. Please log in again.',
      403 => 'Access denied.',
      404 => 'The requested resource was not found.',
      429 => 'Too many requests. Please try again later.',
      500 => 'Server error. Please try again later.',
      502 => 'Bad gateway. Please try again later.',
      503 => 'Service unavailable. Please try again later.',
      _ => 'An error occurred. Please try again.',
    };
  }
}
