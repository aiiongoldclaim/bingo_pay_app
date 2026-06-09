import 'package:bloc_test/bloc_test.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/get_kyc_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/login_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/submit_kyc_personal_details_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_document_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_selfie_usecase.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_event.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}
class MockKycPersonalDetailsUseCase extends Mock implements SubmitKycPersonalDetailsUseCase {}
class MockKycDocumentUseCase extends Mock implements UploadKycDocumentUseCase {}
class MockKycSelfieUseCase extends Mock implements UploadKycSelfieUseCase {}
class MockGetKycStatusUseCase extends Mock implements GetKycStatusUseCase {}

AuthBloc buildBloc({
  MockLoginUseCase? login,
  MockRegisterUseCase? register,
  MockCheckAuthStatusUseCase? checkAuth,
  MockLogoutUseCase? logout,
  MockForgotPasswordUseCase? forgotPassword,
}) =>
    AuthBloc(
      checkAuthStatus: checkAuth ?? MockCheckAuthStatusUseCase(),
      login: login ?? MockLoginUseCase(),
      register: register ?? MockRegisterUseCase(),
      forgotPassword: forgotPassword ?? MockForgotPasswordUseCase(),
      logout: logout ?? MockLogoutUseCase(),
      kycPersonalDetails: MockKycPersonalDetailsUseCase(),
      kycDocument: MockKycDocumentUseCase(),
      kycSelfie: MockKycSelfieUseCase(),
      getKycStatus: MockGetKycStatusUseCase(),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(
      const RegisterParams(email: '', password: '', name: '', role: ''),
    );
  });

  const user = UserEntity(
    id: '1', email: 'a@b.com', name: 'Alice',
    role: 'buyer', kycStatus: 'not_required',
  );

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        final mockLogin = MockLoginUseCase();
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Right(user));
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
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
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
        when(() => mockCheck())
            .thenAnswer((_) async => const Right(user));
        return buildBloc(checkAuth: mockCheck);
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthLoading(), const AuthAuthenticated(user)],
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
