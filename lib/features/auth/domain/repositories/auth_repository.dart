import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String countryId,
  });

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, bool>> checkUserExists({required String email});

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, UserEntity?>> getStoredUser();
}
