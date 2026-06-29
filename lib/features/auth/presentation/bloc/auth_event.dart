import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
  @override
  List<Object> get props => [];
}

class VendorLoginRequested extends AuthEvent {
  final String identifier;
  final String password;
  const VendorLoginRequested({required this.identifier, required this.password});
  @override
  List<Object> get props => [identifier, password];
}

class VendorRegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String shopName;
  final String shopSlug;
  final String businessName;
  final String? description;
  final String? gstNumber;
  final String? panNumber;
  final String? supportEmail;
  final String? supportPhone;
  const VendorRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.shopName,
    required this.shopSlug,
    required this.businessName,
    this.description,
    this.gstNumber,
    this.panNumber,
    this.supportEmail,
    this.supportPhone,
  });
  @override
  List<Object?> get props => [
        firstName, lastName, email, phone, password,
        shopName, shopSlug, businessName,
        description, gstNumber, panNumber, supportEmail, supportPhone,
      ];
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  const VerifyOtpRequested({required this.email, required this.otp});
  @override
  List<Object> get props => [email, otp];
}

class ResendOtpRequested extends AuthEvent {
  final String email;
  const ResendOtpRequested({required this.email});
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
