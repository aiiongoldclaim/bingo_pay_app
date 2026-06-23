import 'package:equatable/equatable.dart';
import '../../data/model/wallet_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final WalletModel wallet;
  final List<TransactionModel> transactions;
  final GoldRateModel goldRate;

  const WalletLoaded({
    required this.wallet,
    required this.transactions,
    required this.goldRate,
  });

  @override
  List<Object?> get props => [wallet, transactions, goldRate];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
