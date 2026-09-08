import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SetPasswordUseCase {
  final AuthRepository _repository;
  const SetPasswordUseCase(this._repository);

  /// Set password for SSO user during first login.
  ///
  /// Returns [Unit] because success is indicated by state transition.
  /// The UI generates its own success message (e.g., "Password set successfully").
  /// Server message is not needed since the action's result is implicit.
  Future<Either<Failure, Unit>> call(String password) =>
      _repository.setPassword(password: password);
}
