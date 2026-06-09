import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class CheckAuthStatusUseCase {
  final AuthRepository _repository;
  const CheckAuthStatusUseCase(this._repository);

  Future<Either<Failure, UserEntity?>> call() => _repository.getStoredUser();
}
