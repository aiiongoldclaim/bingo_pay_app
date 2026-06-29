import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_kyc_status_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_vendor_usecase.dart';
import '../../domain/usecases/submit_kyc_personal_details_usecase.dart';
import '../../domain/usecases/upload_kyc_document_usecase.dart';
import '../../domain/usecases/resend_vendor_otp_usecase.dart';
import '../../domain/usecases/upload_kyc_selfie_usecase.dart';
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
  final VendorLoginUseCase _vendorLogin;
  final LogoutUseCase _logout;
  final UploadKycSelfieUseCase _kycSelfie;

  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatus,
    required RegisterVendorUseCase registerVendor,
    required VerifyVendorOtpUseCase verifyVendorOtp,
    required ResendVendorOtpUseCase resendVendorOtp,
    required VendorLoginUseCase vendorLogin,
    required ForgotPasswordUseCase forgotPassword,
    required LogoutUseCase logout,
    required SubmitKycPersonalDetailsUseCase kycPersonalDetails,
    required UploadKycDocumentUseCase kycDocument,
    required UploadKycSelfieUseCase kycSelfie,
    required GetKycStatusUseCase getKycStatus,
  }) : _checkAuthStatus = checkAuthStatus,
       _registerVendor = registerVendor,
       _verifyVendorOtp = verifyVendorOtp,
       _resendVendorOtp = resendVendorOtp,
       _vendorLogin = vendorLogin,
       _logout = logout,
       _kycSelfie = kycSelfie,
       super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<VendorLoginRequested>(_onVendorLogin);
    on<VendorRegisterRequested>(_onVendorRegister);
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<ResendOtpRequested>(_onResendOtp);
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
    result.match(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        if (user == null) {
          emit(const AuthUnauthenticated());
          return;
        }
        _currentUser = user;
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onVendorLogin(
    VendorLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _vendorLogin(VendorLoginParams(
      identifier: event.identifier,
      password: event.password,
    ));
    result.match(
      (failure) => emit(AuthError(failure)),
      (user) {
        _currentUser = user;
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onVendorRegister(
    VendorRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _registerVendor(VendorRegisterParams(
      firstName: event.firstName,
      lastName: event.lastName,
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
    ));
    result.match(
      (failure) => emit(AuthError(failure)),
      (otpInfo) => emit(
        AuthOtpRequired(email: otpInfo.email, message: otpInfo.message),
      ),
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _verifyVendorOtp(VerifyVendorOtpParams(
      email: event.email,
      otp: event.otp,
    ));
    result.match(
      (failure) => emit(AuthError(failure)),
      (user) {
        _currentUser = user;
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onResendOtp(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _resendVendorOtp(event.email);
    result.match(
      (failure) => emit(AuthError(failure)),
      (otpInfo) => emit(
        AuthOtpRequired(email: otpInfo.email, message: otpInfo.message),
      ),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const PasswordResetSent());
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    _currentUser = null;
    emit(const AuthUnauthenticated());
  }

  Future<void> _onKycPersonalDetails(
    KycPersonalDetailsSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(KycStepCompleted(
      kyc: const KycEntity(status: 'pending'),
      step: 0,
    ));
  }

  Future<void> _onKycDocument(
    KycDocumentUploaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(KycStepCompleted(
      kyc: const KycEntity(status: 'pending'),
      step: 1,
    ));
  }

  Future<void> _onKycSelfie(
    KycSelfieUploaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(const KycLoading());
    final result = await _kycSelfie(event.filePath);
    result.match(
      (failure) => emit(AuthError(failure)),
      (kyc) {
        emit(KycSubmitted(kyc));

        // Update the authenticated user's KYC status and notify the router
        if (_currentUser != null) {
          final updatedUser = UserEntity(
            id: _currentUser!.id,
            email: _currentUser!.email,
            name: _currentUser!.name,
            role: _currentUser!.role,
            kycStatus: kyc.status,
            shopName: _currentUser!.shopName,
            merchantCode: _currentUser!.merchantCode,
            businessName: _currentUser!.businessName,
          );
          _currentUser = updatedUser;
          emit(AuthAuthenticated(updatedUser));
        }
      },
    );
  }

  Future<void> _onKycStatusPoll(
    KycStatusPolled event,
    Emitter<AuthState> emit,
  ) async {
    emit(KycSubmitted(const KycEntity(status: 'under_review')));
  }
}
