import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'interceptors/logging_interceptor.dart';

const String appsScriptBaseUrl =
    'https://script.google.com/macros/s/AKfycby85LjaGj4jqGPw57UxEWCU6ppaVJdy-uAdN69elibmNer_Y0lK1otUj8HqMFAzk5P3kA/exec';

bool _validateStatus(int? status) => status != null && status < 400;

/// Thin Dio wrapper for the Google Apps Script web app backing the
/// Products/Orders sheets. Apps Script answers POST requests with a 302 to a
/// googleusercontent.com content URL instead of the JSON body directly;
/// Dio doesn't follow redirects on POST automatically, so this follows it
/// manually for both GET and POST.
@lazySingleton
class AppsScriptClient {
  final Dio _dio = Dio()
    ..options.validateStatus = _validateStatus
    ..interceptors.add(LoggingInterceptor());

  Future<Map<String, dynamic>> get(String action, {Map<String, dynamic>? query}) async {
    final response = await _dio.get(
      appsScriptBaseUrl,
      queryParameters: {'action': action, ...?query},
    );
    return _unwrap(await _followRedirect(response));
  }

  Future<Map<String, dynamic>> post(String action, Map<String, dynamic> data) async {
    final response = await _dio.post(
      appsScriptBaseUrl,
      queryParameters: {'action': action},
      data: data,
    );
    return _unwrap(await _followRedirect(response));
  }

  Future<Response> _followRedirect(Response response) async {
    if (response.statusCode == null || response.statusCode! < 300) return response;
    final location = response.headers.value('location');
    if (location == null) {
      throw Exception('Request failed: no redirect location');
    }
    return _dio.get(location);
  }

  Map<String, dynamic> _unwrap(Response response) {
    final data = response.data;
    final success = data is Map && data['success'] == true;
    if (!success) {
      final message = data is Map ? data['message'] : null;
      throw Exception(message ?? 'Request failed');
    }
    return Map<String, dynamic>.from(data);
  }
}
