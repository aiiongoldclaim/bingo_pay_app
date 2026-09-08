import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class ForgotPasswordUseCase {
  final AuthRepository _repository;
  const ForgotPasswordUseCase(this._repository);

  /// Request password reset link for email.
  ///
  /// Returns [String] message from server because the message should be displayed to user.
  /// Example: "Check your email for password reset instructions" or "Reset link sent to your email".
  /// Server message is semantically important for user feedback.
  Future<Either<Failure, String>> call(String email) =>
      _repository.forgotPassword(email: email);
}
