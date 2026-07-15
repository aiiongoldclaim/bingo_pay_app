import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/bingold_login_result_entity.dart';
import '../entities/kyc_entity.dart';
import '../entities/register_otp_entity.dart';
import '../entities/user_entity.dart';
import '../entities/user_existence_entity.dart';
import '../usecases/submit_vendor_kyc_usecase.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, RegisterOtpEntity>> registerVendor({
    required String fullName,
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

  Future<Either<Failure, UserEntity>> verifyVendorOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, RegisterOtpEntity>> resendVendorOtp({
    required String email,
  });

  Future<Either<Failure, UserExistenceEntity>> checkEmailExists({required String email});

  Future<Either<Failure, UserEntity>> vendorLogin({
    required String identifier,
    required String password,
  });

  Future<Either<Failure, RegisterOtpEntity>> bingoldLoginOtp({
    required String email,
  });

  Future<Either<Failure, BinGoldLoginResultEntity>> bingoldVerifyLogin({
    required String email,
    required String otp,
  });

  Future<Either<Failure, UserEntity>> setPassword({required String password});

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, UserEntity?>> getStoredUser();

  Future<Either<Failure, KycEntity>> submitVendorKyc({
    required String kybMode,
    required List<KycDocumentSubmission> documents,
  });

  Future<Either<Failure, KycEntity>> getKycStatus();
}
