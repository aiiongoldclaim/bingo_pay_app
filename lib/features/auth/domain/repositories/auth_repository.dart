import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerBuyer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerVendor({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String shopName,
    required String shopSlug,
    required String businessName,
    String? description,
    String? gstNumber,
    String? panNumber,
    String? supportEmail,
    String? supportPhone,
  });

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, UserEntity?>> getStoredUser();

  Future<Either<Failure, KycEntity>> submitKycPersonalDetails({
    required String name,
    required String dateOfBirth,
    required String address,
  });

  Future<Either<Failure, KycEntity>> uploadKycDocument({
    required String filePath,
    required String documentType,
  });

  Future<Either<Failure, KycEntity>> uploadKycSelfie({required String filePath});

  Future<Either<Failure, KycEntity>> getKycStatus();
}
