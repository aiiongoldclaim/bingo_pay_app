import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart' as log;
import '../../domain/entities/email_existence_result.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/entities/register_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(
    this._remote,
    this._local,
  );

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remote.login(
        email: email,
        password: password,
      );

      await _local.saveTokens(
        accessToken: result.token,
        refreshToken: result.refreshToken,
      );

      await _local.saveUser(result.user);

      return Right(result.user);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, RegisterEntity>> register({
    required String fullName,
    required String password,
    required String countryId,
    required String email,
    required String phone,
  }) async {
    try {
      final result = await _remote.register(
        fullName: fullName,
        password: password,
        countryId: countryId,
        email: email,
        phone: phone,
      );

      return Right(result.data);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final result = await _remote.verifyOtp(
        email: email,
        otp: otp,
      );

      await _local.saveTokens(
        accessToken: result.token,
        refreshToken: result.refreshToken,
      );

      await _local.saveUser(result.user);

      return Right(result.user);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> sendSsoLoginOtp({
    required String email,
  }) async {
    try {
      await _remote.sendSsoLoginOtp(
        email: email,
      );

      return const Right(unit);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifySsoLogin({
    required String email,
    required String otp,
  }) async {
    try {
      final result = await _remote.verifySsoLogin(
        email: email,
        otp: otp,
      );

      await _local.saveTokens(
        accessToken: result.token,
        refreshToken: result.refreshToken,
      );

      await _local.saveUser(result.user);

      return Right(result.user);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setPassword({
    required String password,
  }) async {
    try {
      await _remote.setPassword(
        password: password,
      );

      return const Right(unit);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> sendOtp({
    required String email,
  }) async {
    try {
      await _remote.sendOtp(
        email: email,
      );

      return const Right(unit);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({
    required String email,
  }) async {
    try {
      await _remote.resendOtp(
        email: email,
      );

      return const Right(unit);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, EmailExistenceResult>> checkEmailExists({
    required String email,
  }) async {
    try {
      final result = await _remote.checkEmailExists(
        email: email,
      );

      return Right(result);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword({
    required String email,
  }) async {
    try {
      final message = await _remote.forgotPassword(
        email: email,
      );

      return Right(message);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  /// Logout the user by clearing local credentials and optionally notifying the server.
  ///
  /// This is a **best-effort** logout:
  /// - **Remote logout**: Attempts to notify the server to invalidate the session/token.
  ///   If this fails (network, server error, etc.), the failure is logged but does NOT
  ///   prevent local logout from proceeding.
  /// - **Local logout**: Always clears local credentials/tokens, ensuring the app
  ///   appears logged out to the user even if remote logout fails.
  ///
  /// Rationale: If the server is unreachable or has an error, the user should still
  /// be able to log out of the app. The server can clean up stale sessions using
  /// token expiration or other mechanisms.
  ///
  /// Returns the server message if remote logout succeeds, or a default message
  /// if remote logout fails but local logout succeeds.
  @override
  Future<Either<Failure, String>> logout() async {
    String message = 'Logged out successfully';

    // Attempt remote logout (best-effort, failures are logged but not fatal)
    try {
      message = await _remote.logout();
    } catch (e) {
      // Log the remote logout failure for debugging/monitoring, but don't expose it
      log.AppLogger.logError('Remote logout failed (best-effort, proceeding with local logout)', e);
      // Use default success message since local logout will proceed
    }

    // Always clear local credentials, even if remote logout failed
    try {
      await _local.clearAll();
      return Right(message);
    } catch (e) {
      // Local logout failure IS a problem - user is stuck in a bad state
      log.AppLogger.logError('Local logout failed (critical)', e);
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getStoredUser() async {
    try {
      final user = await _local.getUser();

      return Right(user);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
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
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
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
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, KycEntity>> uploadKycSelfie({
    required String filePath,
  }) async {
    try {
      final kyc = await _remote.uploadKycSelfie(
        filePath: filePath,
      );

      return Right(kyc);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }

  @override
  Future<Either<Failure, KycEntity>> getKycStatus() async {
    try {
      final kyc = await _remote.getKycStatus();

      return Right(kyc);
    } catch (e) {
      return Left(
        ErrorHandler.mapObjectToFailure(e),
      );
    }
  }
}