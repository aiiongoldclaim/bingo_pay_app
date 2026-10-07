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

  final double bigoldBalance;

  const WalletLoaded({
    required this.wallet,
    required this.transactions,
    required this.goldRate,
    required this.bigoldBalance,
  });

  String get formattedBigoldBalance {
    if (bigoldBalance <= 0) return '0 Bigod';
    final s = bigoldBalance
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return '$s Bigod';
  }

  @override
  List<Object?> get props => [wallet, transactions, goldRate, bigoldBalance];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
