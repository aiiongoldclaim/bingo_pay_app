import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SetPasswordUseCase {
  final AuthRepository _repository;
  const SetPasswordUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(String password) =>
      _repository.setPassword(password: password);
}
