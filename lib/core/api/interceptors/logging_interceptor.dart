import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

/// Logs API traffic in dev/staging with sensitive fields redacted so
/// passwords, OTPs, and tokens never reach device logs.
class LoggingInterceptor extends Interceptor {
  static const _sensitiveKeys = {
    'password',
    'confirmpassword',
    'confirm_password',
    'currentpassword',
    'current_password',
    'newpassword',
    'new_password',
    'otp',
    'pin',
    'token',
    'accesstoken',
    'access_token',
    'refreshtoken',
    'refresh_token',
    'authorization',
    'apikey',
    'api_key',
    'x-api-key',
  };

  bool get _enabled =>
      FlavorConfig.instance.variables['enableLogging'] as bool? ?? false;

  static bool _isSensitive(String key) =>
      _sensitiveKeys.contains(key.toLowerCase());

  static Object? _sanitize(Object? data) {
    if (data is Map) {
      return {
        for (final e in data.entries)
          e.key: _isSensitive(e.key.toString())
              ? '***REDACTED***'
              : _sanitize(e.value),
      };
    }
    if (data is List) return data.map(_sanitize).toList();
    if (data is FormData) {
      return {
        for (final f in data.fields)
          f.key: _isSensitive(f.key) ? '***REDACTED***' : f.value,
        for (final f in data.files) f.key: 'file: ${f.value.filename}',
      };
    }
    return data;
  }

  static String _pretty(Object? data) {
    final sanitized = _sanitize(data);
    try {
      return const JsonEncoder.withIndent('  ').convert(sanitized);
    } catch (_) {
      return sanitized.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_enabled) {
      debugPrint('→ ${options.method} ${options.uri}');
      debugPrint('  headers: ${_pretty(options.headers)}');
      if (options.data != null) {
        debugPrint('  body: ${_pretty(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_enabled) {
      final req = response.requestOptions;
      debugPrint('← ${response.statusCode} ${req.method} ${req.uri}');
      if (response.data != null) {
        debugPrint('  body: ${_pretty(response.data)}');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_enabled) {
      final req = err.requestOptions;
      debugPrint(
          '✗ ${err.response?.statusCode ?? err.type.name} ${req.method} ${req.uri}');
      if (err.response?.data != null) {
        debugPrint('  body: ${_pretty(err.response!.data)}');
      }
    }
    handler.next(err);
  }
}
