import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/register_otp_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class ResendVendorOtpUseCase {
  final AuthRepository _repository;
  const ResendVendorOtpUseCase(this._repository);

  Future<Either<Failure, RegisterOtpEntity>> call(String email) =>
      _repository.resendVendorOtp(email: email);
}
