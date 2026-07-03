import '../data/models/transaction_model.dart';

abstract class TransactionsState {}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> all;
  final List<TransactionModel> filtered;
  final String activeFilter; // 'All' | 'Success' | 'Pending' | 'Failed'

  TransactionsLoaded({
    required this.all,
    required this.filtered,
    required this.activeFilter,
  });
}

class TransactionsError extends TransactionsState {
  final String message;
  TransactionsError(this.message);
}
