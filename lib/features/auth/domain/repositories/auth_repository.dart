import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String role,
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
