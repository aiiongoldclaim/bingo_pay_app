import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/email_existence_result.dart';
import '../entities/kyc_entity.dart';
import '../entities/register_entity.dart';
import '../entities/user_entity.dart';

/// Authentication repository following consistent return type conventions:
///
/// **Return type patterns:**
/// 1. **Either<Failure, UserEntity> or RegisterEntity**: Operations returning rich domain data
///    - login, register, verifyOtp, verifySsoLogin, getStoredUser
///    - These operations have domain significance beyond their execution
///
/// 2. **Either<Failure, Unit>**: Side-effect-only operations
///    - sendOtp, resendOtp, sendSsoLoginOtp, setPassword
///    - Success is indicated by state transition; UI generates own success messages
///    - Server message not needed as action result is implicit from state change
///
/// 3. **Either<Failure, String>**: Operations with user-visible messages
///    - forgotPassword, logout
///    - Server returns custom message meant to be displayed to user
///    - Message provides semantic feedback beyond just success/failure
///
/// This pattern ensures use case contracts are predictable and self-documenting.
abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, RegisterEntity>> register({
    required String fullName,
    required String password,
    required String countryId,
    required String email,
    required String phone,
  });

  Future<Either<Failure, UserEntity>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Unit>> sendSsoLoginOtp({required String email});

  Future<Either<Failure, UserEntity>> verifySsoLogin({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Unit>> setPassword({required String password});

  Future<Either<Failure, Unit>> sendOtp({required String email});

  Future<Either<Failure, Unit>> resendOtp({required String email});

  Future<Either<Failure, EmailExistenceResult>> checkEmailExists({
    required String email,
  });

  Future<Either<Failure, String>> forgotPassword({required String email});

  Future<Either<Failure, String>> logout();

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

  Future<Either<Failure, KycEntity>> uploadKycSelfie({
    required String filePath,
  });

  Future<Either<Failure, KycEntity>> getKycStatus();
}
