import 'package:equatable/equatable.dart';

sealed class EmailExistsState extends Equatable {
  const EmailExistsState();
}

class EmailExistsInitial extends EmailExistsState {
  const EmailExistsInitial();
  @override
  List<Object?> get props => [];
}

class EmailExistsChecking extends EmailExistsState {
  const EmailExistsChecking();
  @override
  List<Object?> get props => [];
}

class EmailExistsResult extends EmailExistsState {
  final String email;
  final bool exists;
  const EmailExistsResult({required this.email, required this.exists});
  @override
  List<Object?> get props => [email, exists];
}
