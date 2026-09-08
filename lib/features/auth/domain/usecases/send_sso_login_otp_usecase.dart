import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendSsoLoginOtpUseCase {
  final AuthRepository _repository;
  const SendSsoLoginOtpUseCase(this._repository);

  /// Send OTP to email for SSO login.
  ///
  /// Returns [Unit] because success is indicated by state transition.
  /// The UI generates its own success message (e.g., "OTP sent to email").
  /// Server message is not needed since the action's result is implicit.
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.sendSsoLoginOtp(email: email);
}
