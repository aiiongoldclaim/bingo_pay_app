import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/check_email_exists_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_kyc_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/send_sso_login_otp_usecase.dart';
import '../../domain/usecases/set_password_usecase.dart';
import '../../domain/usecases/submit_kyc_personal_details_usecase.dart';
import '../../domain/usecases/upload_kyc_document_usecase.dart';
import '../../domain/usecases/upload_kyc_selfie_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/verify_sso_login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  UserEntity? _currentUser;
  final SecureStorageService _storage;

  final RegisterUseCase _registerUser;
  final LoginUseCase _loginUser;
  final CheckAuthStatusUseCase _checkAuthStatus;
  final VerifyOtpUseCase _verifyOtp;
  final SendOtpUseCase _sendOtp;
  final ResendOtpUseCase _resendOtp;
  final LogoutUseCase _logoutUser;
  final CheckEmailExistsUseCase _checkEmailExists;
  final SendSsoLoginOtpUseCase _sendSsoLoginOtp;
  final VerifySsoLoginUseCase _verifySsoLogin;
  final SetPasswordUseCase _setPassword;
  final ForgotPasswordUseCase _forgotPassword;

  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatus,
    required LoginUseCase login,
    required RegisterUseCase register,
    required VerifyOtpUseCase verifyOtp,
    required SendOtpUseCase sendOtp,
    required ResendOtpUseCase resendOtp,
    required ForgotPasswordUseCase forgotPassword,
    required LogoutUseCase logout,
    required CheckEmailExistsUseCase checkEmailExists,
    required SendSsoLoginOtpUseCase sendSsoLoginOtp,
    required VerifySsoLoginUseCase verifySsoLogin,
    required SetPasswordUseCase setPassword,
    required SubmitKycPersonalDetailsUseCase kycPersonalDetails,
    required UploadKycDocumentUseCase kycDocument,
    required UploadKycSelfieUseCase kycSelfie,
    required GetKycStatusUseCase getKycStatus,
    required SecureStorageService storage,
  }) : _storage = storage,
       _registerUser = register,
       _loginUser = login,
       _checkAuthStatus = checkAuthStatus,
       _verifyOtp = verifyOtp,
       _sendOtp = sendOtp,
       _resendOtp = resendOtp,
       _logoutUser = logout,
       _checkEmailExists = checkEmailExists,
       _sendSsoLoginOtp = sendSsoLoginOtp,
       _verifySsoLogin = verifySsoLogin,
       _setPassword = setPassword,
       _forgotPassword = forgotPassword,
       super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<OtpVerifyRequested>(_onVerifyOtp);
    on<OtpResendRequested>(_onResendOtp);
    on<OtpSendRequested>(_onSendOtp);
    on<SsoOtpSendRequested>(_onSendSsoLoginOtp);
    on<SsoOtpVerifyRequested>(_onVerifySsoLogin);
    on<SsoSetPasswordRequested>(_onSetSsoPassword);
    on<EmailExistenceCheckRequested>(_onCheckEmailExists);
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
    result.match((failure) => emit(const AuthUnauthenticated()), (user) {
      if (user == null) {
        emit(const AuthUnauthenticated());
        return;
      }
      _currentUser = user;
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final result = await _loginUser(
        LoginParams(email: event.email, password: event.password),
      );
      await result.fold(
        (failure) async {
          emit(AuthError(failure));
        },
        (user) async {
          _currentUser = user;
          await _storage.saveEmail(user.email);
          if (emit.isDone) return;
          emit(AuthAuthenticated(user));
        },
      );
    } on EmailNotVerifiedException {
      final sendResult = await _sendOtp(event.email);
      await sendResult.fold((failure) async => emit(AuthError(failure)), (
        _,
      ) async {
        if (!emit.isDone) emit(AuthOtpRequired(event.email));
      });
    }catch (e) {
      if (!emit.isDone) emit(AuthError(UnknownFailure(e.toString())));
    }
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _registerUser(
      RegisterParams(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
        countryId: event.countryId,
        phone: event.phone,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AuthError(failure));
      },
      (register) async {
        await _storage.saveEmail(register.email);

        if (emit.isDone) return;

        emit(AuthOtpRequired(register.email));
      },
    );
  }

  // Future<void> _onRegister(
  //     RegisterRequested event,
  //     Emitter<AuthState> emit,
  //     ) async {
  //   emit(const AuthLoading());
  //
  //   final result = await _registerUser(
  //     RegisterParams(
  //       firstName: event.firstName,
  //       lastName: event.lastName,
  //       email: event.email,
  //       password: event.password,
  //       countryId: event.countryId,
  //       phoneNumber: event.phoneNumber,
  //     ),
  //   );
  //
  //   result.fold(
  //         (failure) => emit(AuthError(failure)),
  //         (register) => emit(AuthOtpRequired(register.email)),
  //   );
  // }

  Future<void> _onVerifyOtp(
    OtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _verifyOtp(
      VerifyOtpParams(email: event.email, otp: event.otp),
    );

    result.fold((failure) => emit(AuthError(failure)), (user) {
      _currentUser = user;
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onResendOtp(
    OtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _resendOtp(event.email);
    result.match(
      (failure) => emit(AuthError(failure)),
      (_) => emit(const OtpResendSent()),
    );
  }

  Future<void> _onSendOtp(
    OtpSendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _sendOtp(event.email);
    result.match(
      (failure) => emit(AuthError(failure)),
      (_) => emit(AuthOtpRequired(event.email)),
    );
  }

  Future<void> _onSendSsoLoginOtp(
    SsoOtpSendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const SsoOtpSending());
    final result = await _sendSsoLoginOtp(event.email);
    result.match(
      (failure) => emit(AuthError(failure)),
      (_) => emit(SsoOtpRequired(event.email)),
    );
  }

  Future<void> _onVerifySsoLogin(
    SsoOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _verifySsoLogin(
      VerifySsoLoginParams(email: event.email, otp: event.otp),
    );

    await result.fold((failure) async => emit(AuthError(failure)), (
      user,
    ) async {
      _currentUser = user;
      await _storage.saveEmail(user.email);
      if (emit.isDone) return;
      emit(SsoSetPasswordRequired(user.email));
    });
  }

  Future<void> _onSetSsoPassword(
    SsoSetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _setPassword(event.password);

    await result.fold((failure) async => emit(AuthError(failure)), (_) async {
      if (_currentUser == null || emit.isDone) return;
      emit(AuthAuthenticated(_currentUser!));
    });
  }

  Future<void> _onCheckEmailExists(
    EmailExistenceCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const EmailExistenceChecking());
    final result = await _checkEmailExists(event.email);
    result.match(
      (failure) => emit(EmailExistenceCheckFailed(email: event.email)),
      (r) => emit(
        EmailExistenceChecked(
          email: event.email,
          exists: r.exists,
          hasLocalProfile: r.hasLocalProfile,
          localEntry: r.localEntry,
          hasLocalPassword: r.hasLocalPassword,
        ),
      ),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _forgotPassword(event.email);
    result.match(
      (failure) => emit(AuthError(failure)),
      (message) => emit(PasswordResetSent(message)),
    );
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _logoutUser();
    await result.fold((failure) async => emit(AuthError(failure)), (
      message,
    ) async {
      _currentUser = null;
      if (emit.isDone) return;
      emit(AuthLoggedOut(message));
    });
  }

  Future<void> _onKycPersonalDetails(
    KycPersonalDetailsSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(KycStepCompleted(kyc: const KycEntity(status: 'pending'), step: 0));
  }

  Future<void> _onKycDocument(
    KycDocumentUploaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(KycStepCompleted(kyc: const KycEntity(status: 'pending'), step: 1));
  }

  Future<void> _onKycSelfie(
    KycSelfieUploaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(KycSubmitted(const KycEntity(status: 'under_review')));

    // Update the authenticated user's KYC status and notify the router
    if (_currentUser != null) {
      final updatedUser = UserEntity(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: _currentUser!.name,
        kycStatus: 'under_review',
      );
      _currentUser = updatedUser;
      emit(AuthAuthenticated(updatedUser));
    }
  }

  Future<void> _onKycStatusPoll(
    KycStatusPolled event,
    Emitter<AuthState> emit,
  ) async {
    emit(KycSubmitted(const KycEntity(status: 'under_review')));
  }
}
