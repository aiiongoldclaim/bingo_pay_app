import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';
import 'tvs_wallet_state.dart';

// The wallet home: balances, then the home wallet's activity, page by page.
@injectable
class TvsWalletCubit extends Cubit<TvsWalletState> {
  final TvsQrDataSource _api;

  TvsWalletCubit(this._api) : super(const TvsWalletState());

  // Also the refresh: what is on screen stays until the new data arrives.
  Future<void> load() async {
    emit(state.copyWith(error: null));
    try {
      final summary = await _api.walletSummary();
      final wallets = (summary['wallets'] as List?) ?? const [];
      final home = wallets.isEmpty ? null : wallets.first as Map;
      final page = await _api.statement(walletUuid: home?['uuid'] as String?);
      if (isClosed) return;
      emit(
        TvsWalletState(
          summary: summary,
          activity: _items(page),
          nextCursor: page['nextCursor'] as String?,
        ),
      );
    } catch (e) {
      if (!isClosed) emit(state.copyWith(error: _message(e)));
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true, error: null));
    try {
      final page = await _api.statement(
        walletUuid: state.home?['uuid'] as String?,
        cursor: cursor,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          activity: [...state.activity, ..._items(page)],
          nextCursor: page['nextCursor'] as String?,
          loadingMore: false,
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(loadingMore: false, error: _message(e)));
      }
    }
  }

  static List<Map<String, dynamic>> _items(Map<String, dynamic> page) =>
      ((page['items'] as List?) ?? const []).cast<Map<String, dynamic>>();

  String _message(Object e) => ErrorHandler.mapObjectToFailure(e).message;
}
