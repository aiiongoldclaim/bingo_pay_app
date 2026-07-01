import 'package:bloc_test/bloc_test.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/email_existence_result.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_email_exists_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/get_kyc_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/login_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/submit_kyc_personal_details_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_document_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_selfie_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_event.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}

class MockResendOtpUseCase extends Mock implements ResendOtpUseCase {}

class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockCheckEmailExistsUseCase extends Mock
    implements CheckEmailExistsUseCase {}

class MockCheckAuthStatusUseCase extends Mock
    implements CheckAuthStatusUseCase {}

class MockKycPersonalDetailsUseCase extends Mock
    implements SubmitKycPersonalDetailsUseCase {}

class MockKycDocumentUseCase extends Mock implements UploadKycDocumentUseCase {}

class MockKycSelfieUseCase extends Mock implements UploadKycSelfieUseCase {}

class MockGetKycStatusUseCase extends Mock implements GetKycStatusUseCase {}

AuthBloc buildBloc({
  MockLoginUseCase? login,
  MockRegisterUseCase? register,
  MockVerifyOtpUseCase? verifyOtp,
  MockResendOtpUseCase? resendOtp,
  MockCheckAuthStatusUseCase? checkAuth,
  MockLogoutUseCase? logout,
  MockForgotPasswordUseCase? forgotPassword,
  MockCheckEmailExistsUseCase? checkEmailExists,
}) => AuthBloc(
  checkAuthStatus: checkAuth ?? MockCheckAuthStatusUseCase(),
  login: login ?? MockLoginUseCase(),
  register: register ?? MockRegisterUseCase(),
  verifyOtp: verifyOtp ?? MockVerifyOtpUseCase(),
  resendOtp: resendOtp ?? MockResendOtpUseCase(),
  forgotPassword: forgotPassword ?? MockForgotPasswordUseCase(),
  logout: logout ?? MockLogoutUseCase(),
  checkEmailExists: checkEmailExists ?? MockCheckEmailExistsUseCase(),
  kycPersonalDetails: MockKycPersonalDetailsUseCase(),
  kycDocument: MockKycDocumentUseCase(),
  kycSelfie: MockKycSelfieUseCase(),
  getKycStatus: MockGetKycStatusUseCase(),
  storage: '',
);

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(
      const RegisterParams(
        firstName: '',
        lastName: '',
        password: '',
        countryId: '',
        email: '',
        phoneNumber: '',
      ),
    );
    registerFallbackValue(const VerifyOtpParams(email: '', otp: ''));
  });

  const user = UserEntity(
    id: '1',
    email: 'a@b.com',
    name: 'Alice',
    kycStatus: 'not_required',
  );

  const unverifiedUser = UserEntity(
    id: '1',
    email: 'a@b.com',
    name: 'Alice',
    kycStatus: 'pending',
    emailVerified: false,
  );

  const verifiedUser = UserEntity(
    id: '1',
    email: 'a@b.com',
    name: 'Alice',
    kycStatus: 'pending',
    emailVerified: true,
  );

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        final mockLogin = MockLoginUseCase();
        when(() => mockLogin(any())).thenAnswer((_) async => const Right(user));
        return buildBloc(login: mockLogin);
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: 'a@b.com', password: 'pw')),
      expect: () => [const AuthLoading(), const AuthAuthenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        final mockLogin = MockLoginUseCase();
        when(
          () => mockLogin(any()),
        ).thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc(login: mockLogin);
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: 'a@b.com', password: 'pw')),
      expect: () => [const AuthLoading(), const AuthError(NetworkFailure())],
    );
  });

  group('CheckAuthStatusRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when stored user exists',
      build: () {
        final mockCheck = MockCheckAuthStatusUseCase();
        when(() => mockCheck()).thenAnswer((_) async => const Right(user));
        return buildBloc(checkAuth: mockCheck);
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthLoading(), const AuthAuthenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no stored user',
      build: () {
        final mockCheck = MockCheckAuthStatusUseCase();
        when(() => mockCheck()).thenAnswer((_) async => const Right(null));
        return buildBloc(checkAuth: mockCheck);
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });

  group('RegisterRequested', () {
    // OTP verification is temporarily skipped after register (see
    // auth_bloc.dart _onRegister); registering always lands on
    // AuthAuthenticated regardless of emailVerified.
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] even when email is unverified',
      build: () {
        final mockRegister = MockRegisterUseCase();
        when(
          () => mockRegister(any()),
        ).thenAnswer((_) async => const Right(unverifiedUser));
        return buildBloc(register: mockRegister);
      },
      act: (bloc) => bloc.add(
        const RegisterRequested(
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.com',
          password: 'pw',
          countryId: '91',
          phoneNumber: '123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(unverifiedUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when email is already verified',
      build: () {
        final mockRegister = MockRegisterUseCase();
        when(
          () => mockRegister(any()),
        ).thenAnswer((_) async => const Right(verifiedUser));
        return buildBloc(register: mockRegister);
      },
      act: (bloc) => bloc.add(
        const RegisterRequested(
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.com',
          password: 'pw',
          countryId: '91',
          phoneNumber: '123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(verifiedUser),
      ],
    );
  });

  group('OtpVerifyRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        final mockVerify = MockVerifyOtpUseCase();
        when(
          () => mockVerify(any()),
        ).thenAnswer((_) async => const Right(verifiedUser));
        return buildBloc(verifyOtp: mockVerify);
      },
      act: (bloc) =>
          bloc.add(const OtpVerifyRequested(email: 'a@b.com', otp: '123456')),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(verifiedUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on invalid otp',
      build: () {
        final mockVerify = MockVerifyOtpUseCase();
        when(() => mockVerify(any())).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Invalid OTP')),
        );
        return buildBloc(verifyOtp: mockVerify);
      },
      act: (bloc) =>
          bloc.add(const OtpVerifyRequested(email: 'a@b.com', otp: '000000')),
      expect: () => [
        const AuthLoading(),
        const AuthError(AuthFailure(message: 'Invalid OTP')),
      ],
    );
  });

  group('OtpResendRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, OtpResendSent] on success',
      build: () {
        final mockResend = MockResendOtpUseCase();
        when(
          () => mockResend(any()),
        ).thenAnswer((_) async => const Right(unit));
        return buildBloc(resendOtp: mockResend);
      },
      act: (bloc) => bloc.add(const OtpResendRequested(email: 'a@b.com')),
      expect: () => [const AuthLoading(), const OtpResendSent()],
    );
  });

  group('EmailExistenceCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [EmailExistenceChecking, EmailExistenceChecked(exists: true)]',
      build: () {
        final mockCheck = MockCheckEmailExistsUseCase();
        when(() => mockCheck(any())).thenAnswer(
          (_) async => const Right(
            EmailExistenceResult(
              exists: true,
              hasLocalProfile: true,
              localEntry: true,
              hasLocalPassword: true,
            ),
          ),
        );
        return buildBloc(checkEmailExists: mockCheck);
      },
      act: (bloc) =>
          bloc.add(const EmailExistenceCheckRequested(email: 'a@b.com')),
      expect: () => [
        const EmailExistenceChecking(),
        const EmailExistenceChecked(
          email: 'a@b.com',
          exists: true,
          hasLocalProfile: true,
          localEntry: true,
          hasLocalPassword: true,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits only [EmailExistenceChecking] on failure (silently ignored)',
      build: () {
        final mockCheck = MockCheckEmailExistsUseCase();
        when(
          () => mockCheck(any()),
        ).thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc(checkEmailExists: mockCheck);
      },
      act: (bloc) =>
          bloc.add(const EmailExistenceCheckRequested(email: 'a@b.com')),
      expect: () => [const EmailExistenceChecking()],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on success',
      build: () {
        final mockLogout = MockLogoutUseCase();
        when(() => mockLogout()).thenAnswer((_) async => const Right(unit));
        return buildBloc(logout: mockLogout);
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        final mockLogout = MockLogoutUseCase();
        when(
          () => mockLogout(),
        ).thenAnswer((_) async => const Left(CacheFailure(message: 'fail')));
        return buildBloc(logout: mockLogout);
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError(CacheFailure(message: 'fail')),
      ],
    );
  });

  group('ForgotPasswordRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, PasswordResetSent] on success',
      build: () {
        final mockForgot = MockForgotPasswordUseCase();
        when(
          () => mockForgot(any()),
        ).thenAnswer((_) async => const Right(unit));
        return buildBloc(forgotPassword: mockForgot);
      },
      act: (bloc) => bloc.add(const ForgotPasswordRequested(email: 'a@b.com')),
      expect: () => [const AuthLoading(), const PasswordResetSent()],
    );
  });
}
