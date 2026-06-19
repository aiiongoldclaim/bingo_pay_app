import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class VendorLoginUseCase {
  final AuthRepository _repository;
  const VendorLoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(VendorLoginParams params) =>
      _repository.vendorLogin(
        identifier: params.identifier,
        password: params.password,
      );
}

class VendorLoginParams extends Equatable {
  final String identifier;
  final String password;
  const VendorLoginParams({required this.identifier, required this.password});
  @override
  List<Object> get props => [identifier, password];
}
