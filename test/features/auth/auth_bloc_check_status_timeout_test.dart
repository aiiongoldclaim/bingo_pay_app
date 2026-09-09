import 'dart:async';

import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/core/storage/secure_storage_service.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_email_exists_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/get_kyc_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/login_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/send_sso_login_otp_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/set_password_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/submit_kyc_personal_details_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_document_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_selfie_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/verify_sso_login_usecase.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_event.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockCheckAuthStatusUseCase extends Mock
    implements CheckAuthStatusUseCase {}

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockRegisterUseCase extends Mock implements RegisterUseCase {}

class _MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}

class _MockSendOtpUseCase extends Mock implements SendOtpUseCase {}

class _MockResendOtpUseCase extends Mock implements ResendOtpUseCase {}

class _MockForgotPasswordUseCase extends Mock
    implements ForgotPasswordUseCase {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

class _MockCheckEmailExistsUseCase extends Mock
    implements CheckEmailExistsUseCase {}

class _MockSendSsoLoginOtpUseCase extends Mock
    implements SendSsoLoginOtpUseCase {}

class _MockVerifySsoLoginUseCase extends Mock
    implements VerifySsoLoginUseCase {}

class _MockSetPasswordUseCase extends Mock implements SetPasswordUseCase {}

class _MockSubmitKycPersonalDetailsUseCase extends Mock
    implements SubmitKycPersonalDetailsUseCase {}

class _MockUploadKycDocumentUseCase extends Mock
    implements UploadKycDocumentUseCase {}

class _MockUploadKycSelfieUseCase extends Mock
    implements UploadKycSelfieUseCase {}

class _MockGetKycStatusUseCase extends Mock implements GetKycStatusUseCase {}

class _MockSecureStorageService extends Mock
    implements SecureStorageService {}

void main() {
  late _MockCheckAuthStatusUseCase checkAuthStatus;

  AuthBloc buildBloc() {
    return AuthBloc(
      checkAuthStatus: checkAuthStatus,
      login: _MockLoginUseCase(),
      register: _MockRegisterUseCase(),
      verifyOtp: _MockVerifyOtpUseCase(),
      sendOtp: _MockSendOtpUseCase(),
      resendOtp: _MockResendOtpUseCase(),
      forgotPassword: _MockForgotPasswordUseCase(),
      logout: _MockLogoutUseCase(),
      checkEmailExists: _MockCheckEmailExistsUseCase(),
      sendSsoLoginOtp: _MockSendSsoLoginOtpUseCase(),
      verifySsoLogin: _MockVerifySsoLoginUseCase(),
      setPassword: _MockSetPasswordUseCase(),
      kycPersonalDetails: _MockSubmitKycPersonalDetailsUseCase(),
      kycDocument: _MockUploadKycDocumentUseCase(),
      kycSelfie: _MockUploadKycSelfieUseCase(),
      getKycStatus: _MockGetKycStatusUseCase(),
      storage: _MockSecureStorageService(),
    );
  }

  setUp(() {
    checkAuthStatus = _MockCheckAuthStatusUseCase();
  });

  blocTest<AuthBloc, AuthState>(
    'F: a stored-session read that never completes (e.g. a hung Android '
    'Keystore read in flutter_secure_storage) must not strand the bloc in '
    'AuthLoading forever — it resolves to AuthUnauthenticated once the '
    'bounded timeout elapses, so the splash screen is never stuck forever.',
    build: () {
      // Simulate the real-world hang: the use case's Future never completes.
      when(checkAuthStatus.call).thenAnswer(
        (_) => Completer<Either<Failure, UserEntity?>>().future,
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
    wait: const Duration(seconds: 9),
    expect: () => const [AuthLoading(), AuthUnauthenticated()],
  );
}
