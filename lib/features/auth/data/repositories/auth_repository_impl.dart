import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/bingold_login_result_entity.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/entities/register_otp_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_existence_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/submit_vendor_kyc_usecase.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
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
  }) async {
    try {
      final result = await _remote.registerVendor(
        fullName: fullName,
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
      return Right(
        RegisterOtpEntity(email: result.email, message: result.message),
      );
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyVendorOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final result = await _remote.verifyVendorOtp(email: email, otp: otp);
      await _local.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _local.saveUser(result.user);
      await _local.saveVendorData(result.vendorData);
      return Right(result.user);
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, RegisterOtpEntity>> resendVendorOtp({
    required String email,
  }) async {
    try {
      final result = await _remote.resendVendorOtp(email: email);
      return Right(
        RegisterOtpEntity(email: result.email, message: result.message),
      );
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserExistenceEntity>> checkEmailExists({
    required String email,
  }) async {
    try {
      final model = await _remote.checkUserExists(email: email);
      return Right(model.toEntity());
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
      await _local.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _local.saveUser(result.user);
      await _local.saveVendorData(result.vendorData);
      return Right(result.user);
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, RegisterOtpEntity>> bingoldLoginOtp({
    required String email,
  }) async {
    try {
      final result = await _remote.bingoldLoginOtp(email: email);
      return Right(
        RegisterOtpEntity(email: result.email, message: result.message),
      );
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, BinGoldLoginResultEntity>> bingoldVerifyLogin({
    required String email,
    required String otp,
  }) async {
    try {
      final result = await _remote.bingoldVerifyLogin(email: email, otp: otp);
      if (result.requiresPasswordSetup) {
        await _local.saveTempTokens(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
        );
      } else {
        await _local.saveTokens(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
        );
      }
      await _local.saveUser(result.user);
      return Right(BinGoldLoginResultEntity(
        user: result.user,
        requiresPasswordSetup: result.requiresPasswordSetup,
      ));
    } catch (e) {
      return Left(ErrorHandler.mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> setPassword({
    required String password,
  }) async {
    try {
      final accessToken = await _local.getTempAccessToken();
      if (accessToken == null) {
        return const Left(
          AuthFailure(message: 'Session expired. Please verify OTP again.'),
        );
      }
      await _remote.setPassword(accessToken: accessToken, password: password);
      final refreshToken = await _local.getTempRefreshToken();
      await _local.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
      );
      await _local.clearTempTokens();
      final user = await _local.getUser();
      if (user == null) {
        return const Left(
          AuthFailure(message: 'Unable to complete login. Please try again.'),
        );
      }
      return Right(user);
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
  Future<Either<Failure, KycEntity>> submitVendorKyc({
    required String kybMode,
    required List<KycDocumentSubmission> documents,
  }) async {
    try {
      final vendorUuid = (await _local.getVendorData())?['uuid'] as String?;
      if (vendorUuid == null) {
        return const Left(AuthFailure(message: 'Vendor details not found. Please log in again.'));
      }
      final kyc = await _remote.submitVendorKyc(
        vendorUuid: vendorUuid,
        kybMode: kybMode,
        documents: documents,
      );
      final cachedUser = await _local.getUser();
      if (cachedUser != null) {
        await _local.saveUser(UserModel(
          id: cachedUser.id,
          email: cachedUser.email,
          name: cachedUser.name,
          role: cachedUser.role,
          kycStatus: kyc.status,
          kybStatus: cachedUser.kybStatus,
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
