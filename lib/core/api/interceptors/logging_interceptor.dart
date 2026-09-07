import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class LoggingInterceptor extends Interceptor {
  final PrettyDioLogger _logger = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
  );

  bool get _loggingEnabled =>
      FlavorConfig.instance.variables['enableLogging'] as bool? ?? false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!_loggingEnabled) {
      handler.next(options);
      return;
    }

    // IMPORTANT:
    // Do NOT pass sanitized RequestOptions to the real Dio handler.
    // The real request must continue with the original password.
    //
    // For now, log manually with the sanitized body.
    _logRequest(options);

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (_loggingEnabled) {
      _logger.onResponse(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (!_loggingEnabled) {
      handler.next(err);
      return;
    }

    // PrettyDioLogger's error logging can contain the original
    // request body, so log a sanitized error instead.
    _logError(err);

    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    debugPrint('╔╣ Request ║ ${options.method}');
    debugPrint('║  ${options.uri}');
    debugPrint('╚══════════════════════════════════════════════════════════════╝');

    debugPrint('╔ Headers');
    options.headers.forEach((key, value) {
      debugPrint('╟ $key: $value');
    });

    debugPrint('╚══════════════════════════════════════════════════════════════╝');

    debugPrint('╔ Body');

    final sanitizedData = _sanitize(options.data);

    if (sanitizedData is Map) {
      sanitizedData.forEach((key, value) {
        debugPrint('╟ $key: $value');
      });
    } else {
      debugPrint('║ $sanitizedData');
    }

    debugPrint('╚══════════════════════════════════════════════════════════════╝');
  }

  void _logError(DioException error) {
    debugPrint(
      '╔╣ DioError ║ Status: ${error.response?.statusCode}',
    );

    debugPrint(
      '║  ${error.requestOptions.uri}',
    );

    debugPrint(
      '╚══════════════════════════════════════════════════════════════╝',
    );

    debugPrint('╔ Body');

    final sanitizedData = _sanitize(
      error.requestOptions.data,
    );

    if (sanitizedData is Map) {
      sanitizedData.forEach((key, value) {
        debugPrint('╟ $key: $value');
      });
    } else {
      debugPrint('║ $sanitizedData');
    }

    debugPrint('╚══════════════════════════════════════════════════════════════╝');

    if (error.response?.data != null) {
      debugPrint('Response: ${error.response?.data}');
    }
  }

  dynamic _sanitize(dynamic data) {
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(
          key,
          _isSensitiveKey(key.toString())
              ? '***REDACTED***'
              : _sanitize(value),
        ),
      );
    }

    if (data is List) {
      return data.map(_sanitize).toList();
    }

    return data;
  }

  bool _isSensitiveKey(String key) {
    const sensitiveKeys = {
      'password',
      'currentPassword',
      'newPassword',
      'confirmPassword',
      'oldPassword',
    };

    return sensitiveKeys.contains(
      key.toLowerCase(),
    );
  }
}