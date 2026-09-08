import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  /// Logout user and clear local credentials.
  ///
  /// Returns [String] message from server (with fallback) because the message should be displayed to user.
  /// Example: "Logged out successfully" or custom server message.
  /// Uses best-effort approach: remote logout may fail but local logout always proceeds.
  /// Server message is displayed to user for confirmation feedback.
  Future<Either<Failure, String>> call() => _repository.logout();
}
