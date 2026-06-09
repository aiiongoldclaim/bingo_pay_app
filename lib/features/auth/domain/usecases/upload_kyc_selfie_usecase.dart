import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class UploadKycSelfieUseCase {
  final AuthRepository _repository;
  const UploadKycSelfieUseCase(this._repository);

  Future<Either<Failure, KycEntity>> call(String filePath) =>
      _repository.uploadKycSelfie(filePath: filePath);
}
