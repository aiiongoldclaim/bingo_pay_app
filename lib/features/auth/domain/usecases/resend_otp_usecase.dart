import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class ResendOtpUseCase {
  final AuthRepository _repository;
  const ResendOtpUseCase(this._repository);

  /// Resend OTP to email for verification.
  ///
  /// Returns [Unit] because success is indicated by state transition.
  /// The UI generates its own success message (e.g., "OTP resent").
  /// Server message is not needed since the action's result is implicit.
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.resendOtp(email: email);
}
