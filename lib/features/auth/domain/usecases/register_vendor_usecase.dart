import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/register_otp_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterVendorUseCase {
  final AuthRepository _repository;
  const RegisterVendorUseCase(this._repository);

  Future<Either<Failure, RegisterOtpEntity>> call(VendorRegisterParams params) =>
      _repository.registerVendor(
        firstName: params.firstName,
        lastName: params.lastName,
        email: params.email,
        phone: params.phone,
        password: params.password,
        shopName: params.shopName,
        shopSlug: params.shopSlug,
        businessName: params.businessName,
        description: params.description,
        gstNumber: params.gstNumber,
        panNumber: params.panNumber,
        supportEmail: params.supportEmail,
        supportPhone: params.supportPhone,
      );
}

class VendorRegisterParams extends Equatable {
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
  const VendorRegisterParams({
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
