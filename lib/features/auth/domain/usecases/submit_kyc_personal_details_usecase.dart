import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SubmitKycPersonalDetailsUseCase {
  final AuthRepository _repository;
  const SubmitKycPersonalDetailsUseCase(this._repository);

  Future<Either<Failure, KycEntity>> call(KycPersonalDetailsParams params) =>
      _repository.submitKycPersonalDetails(
        name: params.name,
        dateOfBirth: params.dateOfBirth,
        address: params.address,
      );
}

class KycPersonalDetailsParams extends Equatable {
  final String name;
  final String dateOfBirth;
  final String address;
  const KycPersonalDetailsParams({
    required this.name,
    required this.dateOfBirth,
    required this.address,
  });
  @override
  List<Object> get props => [name, dateOfBirth, address];
}
