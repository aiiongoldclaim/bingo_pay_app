import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendSsoLoginOtpUseCase {
  final AuthRepository _repository;
  const SendSsoLoginOtpUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String email) =>
      _repository.sendSsoLoginOtp(email: email);
}
