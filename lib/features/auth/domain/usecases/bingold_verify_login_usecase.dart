import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/bingold_login_result_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class BinGoldVerifyLoginUseCase {
  final AuthRepository _repository;
  const BinGoldVerifyLoginUseCase(this._repository);

  Future<Either<Failure, BinGoldLoginResultEntity>> call(
    BinGoldVerifyLoginParams params,
  ) =>
      _repository.bingoldVerifyLogin(email: params.email, otp: params.otp);
}

class BinGoldVerifyLoginParams extends Equatable {
  final String email;
  final String otp;
  const BinGoldVerifyLoginParams({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}
