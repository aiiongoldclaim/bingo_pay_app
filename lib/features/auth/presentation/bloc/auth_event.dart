import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String countryId;
  final String phoneNumber;
  const RegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.countryId,
    required this.phoneNumber,
  });
  @override
  List<Object> get props =>
      [firstName, lastName, email, password, countryId, phoneNumber];
}

class OtpVerifyRequested extends AuthEvent {
  final String email;
  final String otp;
  const OtpVerifyRequested({required this.email, required this.otp});
  @override
  List<Object> get props => [email, otp];
}

class OtpResendRequested extends AuthEvent {
  final String email;
  const OtpResendRequested({required this.email});
  @override
  List<Object> get props => [email];
}

class EmailExistenceCheckRequested extends AuthEvent {
  final String email;
  const EmailExistenceCheckRequested({required this.email});
  @override
  List<Object> get props => [email];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested({required this.email});
  @override
  List<Object> get props => [email];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
  @override
  List<Object> get props => [];
}

class KycPersonalDetailsSubmitted extends AuthEvent {
  final String name;
  final String dateOfBirth;
  final String address;
  const KycPersonalDetailsSubmitted({
    required this.name,
    required this.dateOfBirth,
    required this.address,
  });
  @override
  List<Object> get props => [name, dateOfBirth, address];
}

class KycDocumentUploaded extends AuthEvent {
  final String filePath;
  final String documentType;
  const KycDocumentUploaded({
    required this.filePath,
    required this.documentType,
  });
  @override
  List<Object> get props => [filePath, documentType];
}

class KycSelfieUploaded extends AuthEvent {
  final String filePath;
  const KycSelfieUploaded({required this.filePath});
  @override
  List<Object> get props => [filePath];
}

class KycStatusPolled extends AuthEvent {
  const KycStatusPolled();
  @override
  List<Object> get props => [];
}
