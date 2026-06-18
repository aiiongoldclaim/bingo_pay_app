import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.login(email: email, password: password);
      await _local.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _local.saveUser(response.user);
      return Right(response.user);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerBuyer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final result = await _remote.registerBuyer(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
      await _local.saveTokens(accessToken: result.accessToken, refreshToken: '');
      await _local.saveUser(result.user);
      return Right(result.user);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
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
  }) async {
    try {
      final result = await _remote.registerVendor(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        shopName: shopName,
        shopSlug: shopSlug,
        businessName: businessName,
        description: description,
        gstNumber: gstNumber,
        panNumber: panNumber,
        supportEmail: supportEmail,
        supportPhone: supportPhone,
      );
      await _local.saveTokens(accessToken: result.accessToken, refreshToken: '');
      await _local.saveUser(result.user);
      return Right(result.user);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({
    required String email,
  }) async {
    try {
      await _remote.forgotPassword(email: email);
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _local.clearAll();
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getStoredUser() async {
    try {
      final user = await _local.getUser();
      return Right(user);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KycEntity>> submitKycPersonalDetails({
    required String name,
    required String dateOfBirth,
    required String address,
  }) async {
    try {
      final kyc = await _remote.submitKycPersonalDetails(
        name: name,
        dateOfBirth: dateOfBirth,
        address: address,
      );
      return Right(kyc);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KycEntity>> uploadKycDocument({
    required String filePath,
    required String documentType,
  }) async {
    try {
      final kyc = await _remote.uploadKycDocument(
        filePath: filePath,
        documentType: documentType,
      );
      return Right(kyc);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KycEntity>> uploadKycSelfie({
    required String filePath,
  }) async {
    try {
      final kyc = await _remote.uploadKycSelfie(filePath: filePath);
      return Right(kyc);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KycEntity>> getKycStatus() async {
    try {
      final kyc = await _remote.getKycStatus();
      return Right(kyc);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }
}
