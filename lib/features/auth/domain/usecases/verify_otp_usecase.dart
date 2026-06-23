import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyOtpUseCase {
  final AuthRepository _repository;
  const VerifyOtpUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(VerifyOtpParams params) =>
      _repository.verifyOtp(email: params.email, otp: params.otp);
}

class VerifyOtpParams extends Equatable {
  final String email;
  final String otp;
  const VerifyOtpParams({required this.email, required this.otp});
  @override
  List<Object> get props => [email, otp];
}
