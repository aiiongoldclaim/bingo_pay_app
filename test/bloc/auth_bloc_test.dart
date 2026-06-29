import 'package:bloc_test/bloc_test.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/register_otp_entity.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/get_kyc_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_vendor_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/resend_vendor_otp_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/submit_kyc_personal_details_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_document_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_selfie_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/vendor_login_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/verify_vendor_otp_usecase.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_event.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockVendorLoginUseCase extends Mock implements VendorLoginUseCase {}
class MockRegisterVendorUseCase extends Mock implements RegisterVendorUseCase {}
class MockVerifyVendorOtpUseCase extends Mock implements VerifyVendorOtpUseCase {}
class MockResendVendorOtpUseCase extends Mock implements ResendVendorOtpUseCase {}
class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}
class MockKycPersonalDetailsUseCase extends Mock implements SubmitKycPersonalDetailsUseCase {}
class MockKycDocumentUseCase extends Mock implements UploadKycDocumentUseCase {}
class MockKycSelfieUseCase extends Mock implements UploadKycSelfieUseCase {}
class MockGetKycStatusUseCase extends Mock implements GetKycStatusUseCase {}

AuthBloc buildBloc({
  MockVendorLoginUseCase? vendorLogin,
  MockRegisterVendorUseCase? registerVendor,
  MockVerifyVendorOtpUseCase? verifyVendorOtp,
  MockResendVendorOtpUseCase? resendVendorOtp,
  MockCheckAuthStatusUseCase? checkAuth,
  MockLogoutUseCase? logout,
  MockForgotPasswordUseCase? forgotPassword,
}) =>
    AuthBloc(
      checkAuthStatus: checkAuth ?? MockCheckAuthStatusUseCase(),
      vendorLogin: vendorLogin ?? MockVendorLoginUseCase(),
      registerVendor: registerVendor ?? MockRegisterVendorUseCase(),
      verifyVendorOtp: verifyVendorOtp ?? MockVerifyVendorOtpUseCase(),
      resendVendorOtp: resendVendorOtp ?? MockResendVendorOtpUseCase(),
      forgotPassword: forgotPassword ?? MockForgotPasswordUseCase(),
      logout: logout ?? MockLogoutUseCase(),
      kycPersonalDetails: MockKycPersonalDetailsUseCase(),
      kycDocument: MockKycDocumentUseCase(),
      kycSelfie: MockKycSelfieUseCase(),
      getKycStatus: MockGetKycStatusUseCase(),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const VendorRegisterParams(
      firstName: '', lastName: '', email: '', phone: '', password: '',
      shopName: '', shopSlug: '', businessName: '',
    ));
    registerFallbackValue(const VendorLoginParams(identifier: '', password: ''));
    registerFallbackValue(const VerifyVendorOtpParams(email: '', otp: ''));
  });

  const vendor = UserEntity(
    id: '2', email: 'owner@acme.com', name: 'Acme Owner',
    role: 'vendor', kycStatus: 'pending',
  );

  const otpInfo = RegisterOtpEntity(
    email: 'owner@acme.com',
    message: 'OTP sent to your email. Verify it to complete vendor registration.',
  );

  group('VendorLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        final mockVendorLogin = MockVendorLoginUseCase();
        when(() => mockVendorLogin(any()))
            .thenAnswer((_) async => const Right(vendor));
        return buildBloc(vendorLogin: mockVendorLogin);
      },
      act: (bloc) => bloc.add(const VendorLoginRequested(
        identifier: 'owner@acme.com', password: 'Secret@123',
      )),
      expect: () => [const AuthLoading(), const AuthAuthenticated(vendor)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        final mockVendorLogin = MockVendorLoginUseCase();
        when(() => mockVendorLogin(any()))
            .thenAnswer((_) async => const Left(AuthFailure(message: 'Invalid credentials')));
        return buildBloc(vendorLogin: mockVendorLogin);
      },
      act: (bloc) => bloc.add(const VendorLoginRequested(
        identifier: 'owner@acme.com', password: 'wrong-password',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(AuthFailure(message: 'Invalid credentials')),
      ],
    );
  });

  group('VendorRegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthOtpRequired] on success',
      build: () {
        final mockRegister = MockRegisterVendorUseCase();
        when(() => mockRegister(any()))
            .thenAnswer((_) async => const Right(otpInfo));
        return buildBloc(registerVendor: mockRegister);
      },
      act: (bloc) => bloc.add(const VendorRegisterRequested(
        firstName: 'Acme', lastName: 'Owner', email: 'owner@acme.com',
        phone: '9876543210', password: 'password1',
        shopName: 'Acme Store', shopSlug: 'acme-store',
        businessName: 'Acme Pvt Ltd',
      )),
      expect: () => [
        const AuthLoading(),
        AuthOtpRequired(email: otpInfo.email, message: otpInfo.message),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        final mockRegister = MockRegisterVendorUseCase();
        when(() => mockRegister(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc(registerVendor: mockRegister);
      },
      act: (bloc) => bloc.add(const VendorRegisterRequested(
        firstName: 'Acme', lastName: 'Owner', email: 'owner@acme.com',
        phone: '9876543210', password: 'password1',
        shopName: 'Acme Store', shopSlug: 'acme-store',
        businessName: 'Acme Pvt Ltd',
      )),
      expect: () => [const AuthLoading(), const AuthError(NetworkFailure())],
    );
  });

  group('VerifyOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        final mockVerifyOtp = MockVerifyVendorOtpUseCase();
        when(() => mockVerifyOtp(any()))
            .thenAnswer((_) async => const Right(vendor));
        return buildBloc(verifyVendorOtp: mockVerifyOtp);
      },
      act: (bloc) => bloc.add(const VerifyOtpRequested(
        email: 'owner@acme.com', otp: '942653',
      )),
      expect: () => [const AuthLoading(), const AuthAuthenticated(vendor)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        final mockVerifyOtp = MockVerifyVendorOtpUseCase();
        when(() => mockVerifyOtp(any()))
            .thenAnswer((_) async => const Left(ValidationFailure(
                  message: 'Invalid OTP',
                  fieldErrors: {},
                )));
        return buildBloc(verifyVendorOtp: mockVerifyOtp);
      },
      act: (bloc) => bloc.add(const VerifyOtpRequested(
        email: 'owner@acme.com', otp: '000000',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(ValidationFailure(message: 'Invalid OTP', fieldErrors: {})),
      ],
    );
  });

  group('ResendOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthOtpRequired] on success',
      build: () {
        final mockResend = MockResendVendorOtpUseCase();
        when(() => mockResend(any())).thenAnswer((_) async => const Right(otpInfo));
        return buildBloc(resendVendorOtp: mockResend);
      },
      act: (bloc) => bloc.add(const ResendOtpRequested(email: 'owner@acme.com')),
      expect: () => [
        const AuthLoading(),
        AuthOtpRequired(email: otpInfo.email, message: otpInfo.message),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        final mockResend = MockResendVendorOtpUseCase();
        when(() => mockResend(any())).thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc(resendVendorOtp: mockResend);
      },
      act: (bloc) => bloc.add(const ResendOtpRequested(email: 'owner@acme.com')),
      expect: () => [const AuthLoading(), const AuthError(NetworkFailure())],
    );
  });

  group('CheckAuthStatusRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when stored user exists',
      build: () {
        final mockCheck = MockCheckAuthStatusUseCase();
        when(() => mockCheck())
            .thenAnswer((_) async => const Right(vendor));
        return buildBloc(checkAuth: mockCheck);
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthLoading(), const AuthAuthenticated(vendor)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no stored user',
      build: () {
        final mockCheck = MockCheckAuthStatusUseCase();
        when(() => mockCheck())
            .thenAnswer((_) async => const Right(null));
        return buildBloc(checkAuth: mockCheck);
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });

  group('ForgotPasswordRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, PasswordResetSent] on success',
      build: () {
        final mockForgot = MockForgotPasswordUseCase();
        when(() => mockForgot(any()))
            .thenAnswer((_) async => const Right(unit));
        return buildBloc(forgotPassword: mockForgot);
      },
      act: (bloc) =>
          bloc.add(const ForgotPasswordRequested(email: 'a@b.com')),
      expect: () => [const AuthLoading(), const PasswordResetSent()],
    );
  });
}
