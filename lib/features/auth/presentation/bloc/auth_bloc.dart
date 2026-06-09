import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_kyc_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/submit_kyc_personal_details_usecase.dart';
import '../../domain/usecases/upload_kyc_document_usecase.dart';
import '../../domain/usecases/upload_kyc_selfie_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase _checkAuthStatus;
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final ForgotPasswordUseCase _forgotPassword;
  final LogoutUseCase _logout;
  final SubmitKycPersonalDetailsUseCase _kycPersonalDetails;
  final UploadKycDocumentUseCase _kycDocument;
  final UploadKycSelfieUseCase _kycSelfie;
  final GetKycStatusUseCase _getKycStatus;

  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatus,
    required LoginUseCase login,
    required RegisterUseCase register,
    required ForgotPasswordUseCase forgotPassword,
    required LogoutUseCase logout,
    required SubmitKycPersonalDetailsUseCase kycPersonalDetails,
    required UploadKycDocumentUseCase kycDocument,
    required UploadKycSelfieUseCase kycSelfie,
    required GetKycStatusUseCase getKycStatus,
  })  : _checkAuthStatus = checkAuthStatus,
        _login = login,
        _register = register,
        _forgotPassword = forgotPassword,
        _logout = logout,
        _kycPersonalDetails = kycPersonalDetails,
        _kycDocument = kycDocument,
        _kycSelfie = kycSelfie,
        _getKycStatus = getKycStatus,
        super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<LogoutRequested>(_onLogout);
    on<KycPersonalDetailsSubmitted>(_onKycPersonalDetails);
    on<KycDocumentUploaded>(_onKycDocument);
    on<KycSelfieUploaded>(_onKycSelfie);
    on<KycStatusPolled>(_onKycStatusPoll);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _checkAuthStatus();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _login(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _register(
      RegisterParams(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _forgotPassword(event.email);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(const PasswordResetSent()),
    );
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onKycPersonalDetails(
    KycPersonalDetailsSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const KycLoading());
    final result = await _kycPersonalDetails(
      KycPersonalDetailsParams(
        name: event.name,
        dateOfBirth: event.dateOfBirth,
        address: event.address,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (kyc) => emit(KycStepCompleted(kyc: kyc, step: 0)),
    );
  }

  Future<void> _onKycDocument(
    KycDocumentUploaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(const KycLoading());
    final result = await _kycDocument(
      KycDocumentParams(
        filePath: event.filePath,
        documentType: event.documentType,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (kyc) => emit(KycStepCompleted(kyc: kyc, step: 1)),
    );
  }

  Future<void> _onKycSelfie(
    KycSelfieUploaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(const KycLoading());
    final result = await _kycSelfie(event.filePath);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (kyc) => emit(KycSubmitted(kyc)),
    );
  }

  Future<void> _onKycStatusPoll(
    KycStatusPolled event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getKycStatus();
    result.fold(
      (_) {},
      (kyc) => emit(KycSubmitted(kyc)),
    );
  }
}
