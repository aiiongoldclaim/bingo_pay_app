// Payloads are the API's maps (see TvsQrDataSource).
class TvsWalletState {
  final Map<String, dynamic>? summary; // from GET /tvs-wallet
  final List<Map<String, dynamic>> activity; // the home wallet's statement
  final String? nextCursor; // null: no older activity
  final bool loadingMore;
  final String? error;

  const TvsWalletState({
    this.summary,
    this.activity = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.error,
  });

  List<Map<String, dynamic>> get wallets =>
      ((summary?['wallets'] as List?) ?? const []).cast<Map<String, dynamic>>();

  // The home wallet comes first.
  Map<String, dynamic>? get home => wallets.isEmpty ? null : wallets.first;

  bool get active => home?['status'] == 'ACTIVE';

  static const _keep = Object();

  TvsWalletState copyWith({
    Object? summary = _keep,
    List<Map<String, dynamic>>? activity,
    Object? nextCursor = _keep,
    bool? loadingMore,
    Object? error = _keep,
  }) {
    return TvsWalletState(
      summary: identical(summary, _keep)
          ? this.summary
          : summary as Map<String, dynamic>?,
      activity: activity ?? this.activity,
      nextCursor: identical(nextCursor, _keep)
          ? this.nextCursor
          : nextCursor as String?,
      loadingMore: loadingMore ?? this.loadingMore,
      error: identical(error, _keep) ? this.error : error as String?,
    );
  }
}
