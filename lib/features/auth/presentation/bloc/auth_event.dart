import 'package:equatable/equatable.dart';
import '../../domain/usecases/submit_vendor_kyc_usecase.dart';

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
  final String fullName;
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
    required this.fullName,
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
        fullName, email, phone, password,
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

class BinGoldLoginOtpRequested extends AuthEvent {
  final String email;
  const BinGoldLoginOtpRequested({required this.email});
  @override
  List<Object> get props => [email];
}

class BinGoldVerifyLoginRequested extends AuthEvent {
  final String email;
  final String otp;
  const BinGoldVerifyLoginRequested({required this.email, required this.otp});
  @override
  List<Object> get props => [email, otp];
}

class SetPasswordRequested extends AuthEvent {
  final String password;
  const SetPasswordRequested({required this.password});
  @override
  List<Object> get props => [password];
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

class KycDocumentsSubmitted extends AuthEvent {
  final List<KycDocumentSubmission> documents;
  const KycDocumentsSubmitted({required this.documents});
  @override
  List<Object> get props => [documents];
}

class KycStatusPolled extends AuthEvent {
  const KycStatusPolled();
  @override
  List<Object> get props => [];
}
