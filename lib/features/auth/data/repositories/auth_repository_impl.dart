import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

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
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> vendorLogin({
    required String identifier,
    required String password,
  }) async {
    try {
      final result = await _remote.vendorLogin(
        identifier: identifier,
        password: password,
      );
      await _local.saveTokens(accessToken: result.accessToken, refreshToken: '');
      await _local.saveUser(result.user);
      return Right(result.user);
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({
    required String email,
  }) async {
    try {
      await _remote.forgotPassword(email: email);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _local.clearAll();
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getStoredUser() async {
    try {
      final user = await _local.getUser();
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
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
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
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
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KycEntity>> uploadKycSelfie({
    required String filePath,
  }) async {
    try {
      final kyc = await _remote.uploadKycSelfie(filePath: filePath);
      final cachedUser = await _local.getUser();
      if (cachedUser != null) {
        await _local.saveUser(UserModel(
          id: cachedUser.id,
          email: cachedUser.email,
          name: cachedUser.name,
          role: cachedUser.role,
          kycStatus: kyc.status,
          shopName: cachedUser.shopName,
          merchantCode: cachedUser.merchantCode,
          businessName: cachedUser.businessName,
        ));
      }
      return Right(kyc);
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KycEntity>> getKycStatus() async {
    try {
      final kyc = await _remote.getKycStatus();
      return Right(kyc);
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }
}
