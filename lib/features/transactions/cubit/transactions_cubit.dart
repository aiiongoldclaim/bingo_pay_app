import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../data/datasources/transactions_remote_datasource.dart';
import 'transactions_state.dart';

@injectable
class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionsRemoteDataSource _remote;

  TransactionsCubit(this._remote) : super(TransactionsInitial());

  Future<void> loadTransactions() async {
    emit(TransactionsLoading());
    try {
      final transactions = await _remote.getTransactions();
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(
        TransactionsLoaded(
          all: transactions,
          filtered: transactions,
          activeFilter: 'All',
        ),
      );
    } catch (_) {
      emit(TransactionsError('Unable to load your transactions. Please try again.'));
    }
  }

  void filterTransactions(String filter) {
    final current = state;
    if (current is! TransactionsLoaded) return;

    final filtered = filter == 'All'
        ? current.all
        : current.all.where((t) => t.displayStatus == filter).toList();

    emit(
      TransactionsLoaded(
        all: current.all,
        filtered: filtered,
        activeFilter: filter,
      ),
    );
  }
}
