import 'package:dio/dio.dart';
import '../api_endpoints.dart';
import '../../di/injection.dart';
import '../../router/app_router.dart';
import '../../router/route_guard.dart';
import '../../storage/secure_storage_service.dart';
import '../request_queue_manager.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final RequestQueueManager _queueManager = RequestQueueManager();

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra['authRetried'] == true;
    final isRefreshRequest = err.requestOptions.path.endsWith(
      ApiEndpoints.refresh,
    );

    if (statusCode != 401 || alreadyRetried || isRefreshRequest) {
      handler.next(err);
      return;
    }

    // If already refreshing, wait for refresh to complete then retry
    if (_queueManager.isRefreshing) {
      try {
        await _waitForRefresh();
        // Get the newly saved token and retry the request
        final newToken = await _storage.getAccessToken();
        if (newToken != null) {
          final response = await _retryRequest(err.requestOptions, newToken);
          handler.resolve(response);
        } else {
          await _forceLogout();
          handler.next(err);
        }
      } catch (_) {
        await _forceLogout();
        handler.next(err);
      }
      return;
    }

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _forceLogout();
      handler.next(err);
      return;
    }

    try {
      // Mark that we're starting refresh (blocks other 401s)
      _queueManager.startRefresh();

      final tokens = await _refreshTokens(err.requestOptions, refreshToken);
      if (tokens == null) {
        _queueManager.failRefresh(Exception('Failed to refresh tokens'));
        await _forceLogout();
        handler.next(err);
        return;
      }

      await _storage.saveAccessToken(tokens.accessToken);
      if (tokens.refreshToken != null && tokens.refreshToken!.isNotEmpty) {
        await _storage.saveRefreshToken(tokens.refreshToken!);
      }

      // Signal that refresh is complete
      _queueManager.completeRefresh();

      final response = await _retryRequest(
        err.requestOptions,
        tokens.accessToken,
      );
      handler.resolve(response);
    } catch (_) {
      _queueManager.failRefresh(Exception('Token refresh failed'));
      await _forceLogout();
      handler.next(err);
    }
  }

  Future<void> _waitForRefresh() async {
    final startTime = DateTime.now();
    const maxWait = Duration(seconds: 30);

    while (_queueManager.isRefreshing) {
      if (DateTime.now().difference(startTime) > maxWait) {
        throw Exception('Token refresh timeout');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // Refresh failed (or there was no refresh token to try) — the session is
  // dead, so drop stored tokens and flip the router's auth state. RouteGuard
  // picks this up on the next redirect evaluation and sends the user to
  // AppRoutes.login from wherever they currently are.
  Future<void> _forceLogout() async {
    await _storage.clearAll();
    _queueManager.clear();
    getIt<AppRouter>().updateAuthState(const RouteAuthState.unauthenticated());
  }

  Future<_TokenPair?> _refreshTokens(
    RequestOptions failedRequest,
    String refreshToken,
  ) async {
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: failedRequest.baseUrl,
        connectTimeout: failedRequest.connectTimeout,
        receiveTimeout: failedRequest.receiveTimeout,
        headers: Map<String, dynamic>.from(failedRequest.headers)
          ..remove('Authorization'),
      ),
    );

    final response = await refreshDio.post(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );

    return _extractTokens(response.data);
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions failedRequest,
    String accessToken,
  ) {
    final retryDio = Dio();
    final headers = Map<String, dynamic>.from(failedRequest.headers)
      ..['Authorization'] = 'Bearer $accessToken';

    return retryDio.fetch<dynamic>(
      failedRequest.copyWith(
        headers: headers,
        extra: {...failedRequest.extra, 'authRetried': true},
      ),
    );
  }

  _TokenPair? _extractTokens(dynamic data) {
    final tokenMap = _findTokenMap(data);
    if (tokenMap == null) return null;

    final accessToken = tokenMap['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) return null;

    return _TokenPair(
      accessToken: accessToken,
      refreshToken: tokenMap['refreshToken'] as String?,
    );
  }

  Map<String, dynamic>? _findTokenMap(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    if (data['accessToken'] is String) return data;

    final tokens = data['tokens'];
    if (tokens is Map<String, dynamic>) return tokens;

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      final nestedTokens = _findTokenMap(nestedData);
      if (nestedTokens != null) return nestedTokens;
    }

    return null;
  }
}

class _TokenPair {
  final String accessToken;
  final String? refreshToken;

  const _TokenPair({required this.accessToken, this.refreshToken});
}
