import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/register_otp_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class BinGoldLoginOtpUseCase {
  final AuthRepository _repository;
  const BinGoldLoginOtpUseCase(this._repository);

  Future<Either<Failure, RegisterOtpEntity>> call(String email) =>
      _repository.bingoldLoginOtp(email: email);
}
