import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class ResendOtpUseCase {
  final AuthRepository _repository;
  const ResendOtpUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String email) =>
      _repository.resendOtp(email: email);
}
