import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../enities/profile_entity.dart';
import '../repositories/profile_repository.dart';

@injectable
class GetProfileUseCase {
  final ProfileRepository _repository;
  const GetProfileUseCase(this._repository);

  Future<Either<Failure, ProfileEntity>> call() => _repository.getProfile();
}
