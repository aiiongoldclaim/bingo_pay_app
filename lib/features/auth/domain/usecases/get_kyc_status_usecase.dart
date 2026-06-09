import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetKycStatusUseCase {
  final AuthRepository _repository;
  const GetKycStatusUseCase(this._repository);

  Future<Either<Failure, KycEntity>> call() => _repository.getKycStatus();
}
