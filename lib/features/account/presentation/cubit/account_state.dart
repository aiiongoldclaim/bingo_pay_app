import 'package:equatable/equatable.dart';

import '../../data/account_model/account_model.dart';

abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => [];
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  final AccountModel account;

  const AccountLoaded({required this.account});

  @override
  List<Object?> get props => [account];
}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}
