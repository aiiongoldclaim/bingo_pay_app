import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/email_existence_result.dart';
import '../repositories/auth_repository.dart';

@injectable
class CheckEmailExistsUseCase {
  final AuthRepository _repository;
  const CheckEmailExistsUseCase(this._repository);

  Future<Either<Failure, EmailExistenceResult>> call(String email) =>
      _repository.checkEmailExists(email: email);
}
