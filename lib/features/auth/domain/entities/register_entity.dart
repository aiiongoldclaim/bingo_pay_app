import 'package:equatable/equatable.dart';

class RegisterEntity extends Equatable {
  final bool otpSent;
  final String email;
  final String message;

  const RegisterEntity({
    required this.otpSent,
    required this.email,
    required this.message,
  });

  @override
  List<Object> get props => [otpSent, email, message];
}
