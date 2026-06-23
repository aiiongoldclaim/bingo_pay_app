import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(RegisterParams params) =>
      _repository.register(
        firstName: params.firstName,
        lastName: params.lastName,
        password: params.password,
        countryId: params.countryId,
        email: params.email,
        phoneNumber: params.phoneNumber,
      );
}

class RegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final String password;
  final String countryId;
  final String email;
  final String phoneNumber;
  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.countryId,
    required this.email,
    required this.phoneNumber,
  });
  @override
  List<Object> get props =>
      [firstName, lastName, password, countryId, email, phoneNumber];
}
