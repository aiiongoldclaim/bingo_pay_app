import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifySsoLoginUseCase {
  final AuthRepository _repository;
  const VerifySsoLoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(VerifySsoLoginParams params) =>
      _repository.verifySsoLogin(email: params.email, otp: params.otp);
}

class VerifySsoLoginParams extends Equatable {
  final String email;
  final String otp;
  const VerifySsoLoginParams({required this.email, required this.otp});
  @override
  List<Object> get props => [email, otp];
}
