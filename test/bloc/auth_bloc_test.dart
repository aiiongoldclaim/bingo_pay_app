import 'package:bloc_test/bloc_test.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/login_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_usecase.dart';
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
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(
      const RegisterParams(
        email: '',
        password: '',
        firstName: '',
        lastName: '',
        phoneNumber: '',
        countryId: '',
      ),
    );
  });

  const user = UserEntity(id: '1', email: 'a@b.com', name: 'Alice');

  group('LoginRequested', () {
    late MockLoginUseCase mockLogin;

    setUp(() {
      mockLogin = MockLoginUseCase();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Right(user));
        return buildBloc(login: mockLogin);
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: 'a@b.com', password: 'pw')),
      expect: () => [isA<AuthLoading>(), const AuthAuthenticated(user)],
      verify: (_) {
        verify(
          () => mockLogin(
            const LoginParams(email: 'a@b.com', password: 'pw'),
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc(login: mockLogin);
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: 'a@b.com', password: 'pw')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  group('CheckAuthStatusRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated]',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthUnauthenticated()],
    );
  });

  group('ForgotPasswordRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [PasswordResetSent] on success',
      build: () {
        final mockForgot = MockForgotPasswordUseCase();
        when(() => mockForgot(any()))
            .thenAnswer((_) async => const Right(unit));
        return buildBloc(forgotPassword: mockForgot);
      },
      act: (bloc) =>
          bloc.add(const ForgotPasswordRequested(email: 'a@b.com')),
      expect: () => [const PasswordResetSent()],
    );
  });
}
