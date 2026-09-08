import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendOtpUseCase {
  final AuthRepository _repository;
  const SendOtpUseCase(this._repository);

  /// Send OTP to email for registration verification.
  ///
  /// Returns [Unit] because success is indicated by state transition.
  /// The UI generates its own success message (e.g., "OTP sent").
  /// Server message is not needed since the action's result is implicit.
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.sendOtp(email: email);
}
