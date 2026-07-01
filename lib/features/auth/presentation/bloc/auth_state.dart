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
  const AuthOtpRequired(this.email);
  @override
  List<Object> get props => [email];
}

class OtpResendSent extends AuthState {
  const OtpResendSent();
  @override
  List<Object> get props => [];
}

class EmailExistenceChecking extends AuthState {
  const EmailExistenceChecking();
  @override
  List<Object> get props => [];
}

class EmailExistenceChecked extends AuthState {
  final String email;
  final bool exists;
  final bool hasLocalProfile;
  final bool localEntry;
  // Not sent by backend yet (planned addition) — defaults to false, so it
  // has no effect on requiresSsoLogin until the API starts returning it.
  final bool hasLocalPassword;
  const EmailExistenceChecked({
    required this.email,
    required this.exists,
    this.hasLocalProfile = false,
    this.localEntry = false,
    this.hasLocalPassword = false,
  });

  /// True when the email belongs to an existing BinGold account with a
  /// local profile and entry but no local password set — these users
  /// should be sent to SSO login.
  bool get requiresSsoLogin =>
      exists && hasLocalProfile && localEntry && !hasLocalPassword;

  @override
  List<Object> get props =>
      [email, exists, hasLocalProfile, localEntry, hasLocalPassword];
}

class EmailExistenceCheckFailed extends AuthState {
  final String email;
  const EmailExistenceCheckFailed({required this.email});
  @override
  List<Object> get props => [email];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  List<Object> get props => [];
}

class AuthLoggedOut extends AuthState {
  final String message;
  const AuthLoggedOut(this.message);
  @override
  List<Object> get props => [message];
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
