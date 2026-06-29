import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object> get props => [];
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object> get props => [user];
}

class AuthOtpRequired extends AuthState {
  final String email;
  final String message;
  const AuthOtpRequired({required this.email, required this.message});
  @override
  List<Object> get props => [email, message];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  List<Object> get props => [];
}

class AuthError extends AuthState {
  final Failure failure;
  const AuthError(this.failure);
  @override
  List<Object> get props => [failure];
}

class PasswordResetSent extends AuthState {
  const PasswordResetSent();
  @override
  List<Object> get props => [];
}

class KycLoading extends AuthState {
  const KycLoading();
  @override
  List<Object> get props => [];
}

class KycStepCompleted extends AuthState {
  final KycEntity kyc;
  final int step;
  const KycStepCompleted({required this.kyc, required this.step});
  @override
  List<Object> get props => [kyc, step];
}

class KycSubmitted extends AuthState {
  final KycEntity kyc;
  const KycSubmitted(this.kyc);
  @override
  List<Object> get props => [kyc];
}
