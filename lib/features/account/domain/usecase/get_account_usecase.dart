import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../enities/account_entity.dart';
import '../repositories/account_repository.dart';

@injectable
class GetProfileUseCase {
  final AccountRepository _repository;
  const GetProfileUseCase(this._repository);

  Future<Either<Failure, AccountEntity>> call() => _repository.getProfile();
}
