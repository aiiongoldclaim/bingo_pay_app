import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyVendorOtpUseCase {
  final AuthRepository _repository;
  const VerifyVendorOtpUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(VerifyVendorOtpParams params) =>
      _repository.verifyVendorOtp(email: params.email, otp: params.otp);
}

class VerifyVendorOtpParams extends Equatable {
  final String email;
  final String otp;
  const VerifyVendorOtpParams({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}
