import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterBuyerUseCase {
  final AuthRepository _repository;
  const RegisterBuyerUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(BuyerRegisterParams params) =>
      _repository.registerBuyer(
        firstName: params.firstName,
        lastName: params.lastName,
        email: params.email,
        phone: params.phone,
        password: params.password,
      );
}

class BuyerRegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  const BuyerRegisterParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });
  @override
  List<Object> get props => [firstName, lastName, email, phone, password];
}
