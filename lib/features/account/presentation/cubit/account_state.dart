import 'package:equatable/equatable.dart';
import '../../domain/enities/account_entity.dart';

sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  final AccountEntity account;
  const AccountLoaded(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}
