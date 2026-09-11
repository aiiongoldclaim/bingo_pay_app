import 'dart:async';

/// Result of a token-refresh attempt, shared with every request that was
/// waiting on it.
class RefreshOutcome {
  final String? accessToken;
  final Object? error;

  const RefreshOutcome.success(this.accessToken) : error = null;

  const RefreshOutcome.failure(this.error) : accessToken = null;

  bool get isSuccess => error == null;
}

/// Coordinates token refresh across concurrent requests during 401 errors.
///
/// Only one refresh may be in flight at a time. [claimOrWait] atomically
/// decides, with no `await` in between the check and the claim, whether the
/// caller must perform the refresh itself (returns `null`) or should await
/// another in-flight refresh's result instead of starting a second one
/// (returns a Future).
///
/// This matters because the backend rotates (single-use) refresh tokens: if
/// two requests both call /refresh with the same token, only one succeeds
/// and the other gets a real 401. Letting the loser fall through to its own
/// force-logout would wipe out the winner's freshly-saved valid tokens —
/// the previous boolean-flag implementation had exactly that race, because
/// its check (`isRefreshing`) and its claim (`startRefresh()`) were two
/// separate steps with an `await` in between, wide enough for two
/// concurrent 401s (e.g. the cart and wishlist calls fired together right
/// after login) to both see "not refreshing" and both proceed.
class RequestQueueManager {
  static final RequestQueueManager _instance =
      RequestQueueManager._internal();

  factory RequestQueueManager() => _instance;

  RequestQueueManager._internal();

  Completer<RefreshOutcome>? _inFlight;

  /// Returns `null` if the caller must perform the refresh itself (it is
  /// now the sole owner and must call [completeRefresh] or [failRefresh]
  /// when done). Returns a Future of another caller's in-flight refresh
  /// otherwise — await it instead of starting a redundant refresh.
  Future<RefreshOutcome>? claimOrWait() {
    if (_inFlight != null) return _inFlight!.future;
    _inFlight = Completer<RefreshOutcome>();
    return null;
  }

  bool get isRefreshing => _inFlight != null;

  /// Mark the in-flight refresh as successful and hand the new access
  /// token to everyone who was waiting.
  void completeRefresh(String accessToken) {
    _inFlight?.complete(RefreshOutcome.success(accessToken));
    _inFlight = null;
  }

  /// Mark the in-flight refresh as failed and propagate the failure to
  /// everyone who was waiting.
  void failRefresh(Object error) {
    _inFlight?.complete(RefreshOutcome.failure(error));
    _inFlight = null;
  }

  /// Clear any in-flight refresh (called on logout).
  void clear() {
    if (_inFlight != null && !_inFlight!.isCompleted) {
      _inFlight!.complete(
        RefreshOutcome.failure(Exception('Session cleared')),
      );
    }
    _inFlight = null;
  }
}
