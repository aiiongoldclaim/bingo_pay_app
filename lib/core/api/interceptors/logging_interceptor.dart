import 'package:dio/dio.dart';
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

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (FlavorConfig.instance.variables['enableLogging'] as bool? ?? false) {
      _logger.onRequest(options, handler);
    } else {
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (FlavorConfig.instance.variables['enableLogging'] as bool? ?? false) {
      _logger.onResponse(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (FlavorConfig.instance.variables['enableLogging'] as bool? ?? false) {
      _logger.onError(err, handler);
    } else {
      handler.next(err);
    }
  }
}
