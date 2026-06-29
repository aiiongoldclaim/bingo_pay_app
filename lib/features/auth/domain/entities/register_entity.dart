import 'package:equatable/equatable.dart';

class RegisterEntity extends Equatable {
  final String email;
  final String message;
  final int expiresInMinutes;

  const RegisterEntity({
    required this.email,
    required this.message,
    required this.expiresInMinutes,
  });

  @override
  List<Object> get props => [email, message, expiresInMinutes];
}
