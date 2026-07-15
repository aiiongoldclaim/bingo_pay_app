import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/session_expiry_notifier.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_kyc_status_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_vendor_usecase.dart';
import '../../domain/usecases/set_password_usecase.dart';
import '../../domain/usecases/submit_vendor_kyc_usecase.dart';
import '../../domain/usecases/resend_vendor_otp_usecase.dart';
import '../../domain/usecases/bingold_login_otp_usecase.dart';
import '../../domain/usecases/bingold_verify_login_usecase.dart';
import '../../domain/usecases/vendor_login_usecase.dart';
import '../../domain/usecases/verify_vendor_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  UserEntity? _currentUser;
  final CheckAuthStatusUseCase _checkAuthStatus;
  final RegisterVendorUseCase _registerVendor;
  final VerifyVendorOtpUseCase _verifyVendorOtp;
  final ResendVendorOtpUseCase _resendVendorOtp;
  final BinGoldLoginOtpUseCase _bingoldLoginOtp;
  final BinGoldVerifyLoginUseCase _bingoldVerifyLogin;
  final SetPasswordUseCase _setPassword;
  final VendorLoginUseCase _vendorLogin;
  final ForgotPasswordUseCase _forgotPassword;
  final LogoutUseCase _logout;
  final SubmitVendorKycUseCase _submitVendorKyc;
  final GetKycStatusUseCase _getKycStatus;
  StreamSubscription<void>? _sessionExpirySubscription;

  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatus,
    required RegisterVendorUseCase registerVendor,
    required VerifyVendorOtpUseCase verifyVendorOtp,
    required ResendVendorOtpUseCase resendVendorOtp,
    required BinGoldLoginOtpUseCase bingoldLoginOtp,
    required BinGoldVerifyLoginUseCase bingoldVerifyLogin,
    required SetPasswordUseCase setPassword,
    required VendorLoginUseCase vendorLogin,
    required ForgotPasswordUseCase forgotPassword,
    required LogoutUseCase logout,
    required SubmitVendorKycUseCase submitVendorKyc,
    required GetKycStatusUseCase getKycStatus,
    required SessionExpiryNotifier sessionExpiryNotifier,
  }) : _checkAuthStatus = checkAuthStatus,
       _registerVendor = registerVendor,
       _verifyVendorOtp = verifyVendorOtp,
       _resendVendorOtp = resendVendorOtp,
       _bingoldLoginOtp = bingoldLoginOtp,
       _bingoldVerifyLogin = bingoldVerifyLogin,
       _setPassword = setPassword,
       _vendorLogin = vendorLogin,
       _forgotPassword = forgotPassword,
       _logout = logout,
       _submitVendorKyc = submitVendorKyc,
       _getKycStatus = getKycStatus,
       super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<VendorLoginRequested>(_onVendorLogin);
    on<VendorRegisterRequested>(_onVendorRegister);
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<ResendOtpRequested>(_onResendOtp);
    on<BinGoldLoginOtpRequested>(_onBinGoldLoginOtp);
    on<BinGoldVerifyLoginRequested>(_onBinGoldVerifyLogin);
    on<SetPasswordRequested>(_onSetPassword);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<LogoutRequested>(_onLogout);
    on<KycDocumentsSubmitted>(_onKycDocumentsSubmitted);
    on<KycStatusPolled>(_onKycStatusPoll);

    _sessionExpirySubscription = sessionExpiryNotifier.onSessionExpired.listen((
      _,
    ) {
      if (state is AuthAuthenticated) add(const LogoutRequested());
    });
  }

  @override
  Future<void> close() {
    _sessionExpirySubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _checkAuthStatus();
    final user = result.match((failure) => null, (user) => user);
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    // A vendor who hasn't finished KYB verification yet shouldn't stay
    // logged in across a full app restart (killed + reopened) — force them
    // back to the login screen instead of silently resuming on the KYC
    // screen every time. Only fully approved vendors keep a persistent
    // session.
    if (user.effectiveKybStatus != 'approved') {
      await _logout();
      emit(const AuthUnauthenticated());
      return;
    }
    _currentUser = user;
    emit(AuthAuthenticated(user));
  }

  Future<void> _onVendorLogin(
    VendorLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _vendorLogin(
      VendorLoginParams(identifier: event.identifier, password: event.password),
    );
    result.match((failure) => emit(AuthError(failure)), (user) {
      _currentUser = user;
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onVendorRegister(
    VendorRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _registerVendor(
      VendorRegisterParams(
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        password: event.password,
        shopName: event.shopName,
        shopSlug: event.shopSlug,
        businessName: event.businessName,
        description: event.description,
        gstNumber: event.gstNumber,
        panNumber: event.panNumber,
        supportEmail: event.supportEmail,
        supportPhone: event.supportPhone,
      ),
    );
    result.match(
      (failure) => emit(AuthError(failure)),
      (otpInfo) =>
          emit(AuthOtpRequired(email: otpInfo.email, message: otpInfo.message)),
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _verifyVendorOtp(
      VerifyVendorOtpParams(email: event.email, otp: event.otp),
    );
    result.match((failure) => emit(AuthError(failure)), (user) {
      _currentUser = user;
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onResendOtp(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _resendVendorOtp(event.email);
    result.match(
      (failure) => emit(AuthError(failure)),
      (otpInfo) =>
          emit(AuthOtpRequired(email: otpInfo.email, message: otpInfo.message)),
    );
  }

  Future<void> _onBinGoldLoginOtp(
    BinGoldLoginOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _bingoldLoginOtp(event.email);
    result.match(
      (failure) => emit(AuthError(failure)),
      (otpInfo) =>
          emit(AuthOtpRequired(email: otpInfo.email, message: otpInfo.message)),
    );
  }

  Future<void> _onBinGoldVerifyLogin(
    BinGoldVerifyLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _bingoldVerifyLogin(
      BinGoldVerifyLoginParams(email: event.email, otp: event.otp),
    );
    result.match((failure) => emit(AuthError(failure)), (loginResult) {
      if (loginResult.requiresPasswordSetup) {
        emit(AuthPasswordSetupRequired(email: event.email));
        return;
      }
      _currentUser = loginResult.user;
      emit(AuthAuthenticated(loginResult.user));
    });
  }

  Future<void> _onSetPassword(
    SetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _setPassword(event.password);
    result.match((failure) => emit(AuthError(failure)), (user) {
      _currentUser = user;
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _forgotPassword(event.email);
    result.match(
      (failure) => emit(AuthError(failure)),
      (_) => emit(const PasswordResetSent()),
    );
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _logout();
    _currentUser = null;
    emit(const AuthUnauthenticated());
  }

  Future<void> _onKycDocumentsSubmitted(
    KycDocumentsSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const KycLoading());
    final result = await _submitVendorKyc(
      SubmitVendorKycParams(documents: event.documents),
    );
    result.match((failure) => emit(AuthError(failure)), (kyc) {
      emit(KycSubmitted(kyc));

      // Update the authenticated user's KYC status and notify the router
      if (_currentUser != null) {
        final updatedUser = UserEntity(
          id: _currentUser!.id,
          email: _currentUser!.email,
          name: _currentUser!.name,
          role: _currentUser!.role,
          kycStatus: kyc.status,
          kybStatus: _currentUser!.kybStatus,
          shopName: _currentUser!.shopName,
          merchantCode: _currentUser!.merchantCode,
          businessName: _currentUser!.businessName,
        );
        _currentUser = updatedUser;
        emit(AuthAuthenticated(updatedUser));
      }
    });
  }

  Future<void> _onKycStatusPoll(
    KycStatusPolled event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getKycStatus();
    // A failed poll keeps the current state — the next poll retries.
    result.match((_) {}, (kyc) {
      emit(KycSubmitted(kyc));

      if (_currentUser != null && _currentUser!.kycStatus != kyc.status) {
        final updatedUser = UserEntity(
          id: _currentUser!.id,
          email: _currentUser!.email,
          name: _currentUser!.name,
          role: _currentUser!.role,
          kycStatus: kyc.status,
          kybStatus: _currentUser!.kybStatus,
          shopName: _currentUser!.shopName,
          merchantCode: _currentUser!.merchantCode,
          businessName: _currentUser!.businessName,
        );
        _currentUser = updatedUser;
        emit(AuthAuthenticated(updatedUser));
      }
    });
  }
}
