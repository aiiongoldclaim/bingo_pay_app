import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/register_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<Either<Failure, RegisterEntity>> call(RegisterParams params) =>
      _repository.register(
        fullName: params.fullName,
        password: params.password,
        countryId: params.countryId,
        email: params.email,
        phone: params.phone,
      );
}

class RegisterParams extends Equatable {
  final String fullName;
  final String password;
  final String countryId;
  final String email;
  final String phone;

  const RegisterParams({
    required this.fullName,
    required this.password,
    required this.countryId,
    required this.email,
    required this.phone,
  });

  @override
  List<Object> get props => [fullName, password, countryId, email, phone];
}
