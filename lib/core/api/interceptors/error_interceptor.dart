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

    final message = _extractMessage(response.data) ?? 'Server error';
    final fieldErrors = _extractFieldErrors(response.data);

    return switch (response.statusCode) {
      401 => AuthException(message: message),
      422 => ValidationException(message: message, fieldErrors: fieldErrors),
      _ => ServerException(statusCode: response.statusCode, message: message),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) return data['message'] as String?;
    return null;
  }

  Map<String, String> _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return Map<String, String>.from(data['errors'] as Map);
    }
    return {};
  }
}
