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
        email: params.email,
        password: params.password,
        name: params.name,
        role: params.role,
      );
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String role;
  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
  @override
  List<Object> get props => [email, password, name, role];
}
