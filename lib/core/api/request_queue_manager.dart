/// Manages token refresh state to coordinate concurrent requests during 401 errors.
///
/// When one request gets a 401 and starts token refresh, other concurrent
/// requests will see [isRefreshing] = true and wait for the refresh to complete
/// instead of independently refreshing the token.
class RequestQueueManager {
  static final RequestQueueManager _instance = RequestQueueManager._internal();

  factory RequestQueueManager() {
    return _instance;
  }

  RequestQueueManager._internal();

  bool _isRefreshing = false;

  /// Mark that token refresh is starting
  void startRefresh() {
    _isRefreshing = true;
  }

  /// Mark that token refresh is complete
  void completeRefresh() {
    _isRefreshing = false;
  }

  /// Mark refresh as failed
  void failRefresh(dynamic error) {
    _isRefreshing = false;
  }

  /// Check if currently refreshing
  bool get isRefreshing => _isRefreshing;

  /// Clear the queue (called on logout)
  void clear() {
    _isRefreshing = false;
  }
}
