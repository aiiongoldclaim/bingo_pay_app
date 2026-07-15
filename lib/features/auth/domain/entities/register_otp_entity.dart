import 'package:equatable/equatable.dart';

class RegisterOtpEntity extends Equatable {
  final String email;
  final String message;

  const RegisterOtpEntity({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}
