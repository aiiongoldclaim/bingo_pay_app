import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        debugPrint('[Auth] ${options.method} ${options.path} → Bearer $token');
      }
    } else if (kDebugMode) {
      debugPrint('[Auth] ${options.method} ${options.path} → no token');
    }
    handler.next(options);
  }
}
