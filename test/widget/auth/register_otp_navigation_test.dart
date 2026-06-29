import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/router/route_guard.dart';
import 'package:bingo_pay/features/auth/domain/entities/register_otp_entity.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_email_exists_usecase.dart';
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
import 'package:bingo_pay/features/auth/presentation/bloc/auth_state.dart';
import 'package:bingo_pay/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:bingo_pay/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterVendorUseCase extends Mock implements RegisterVendorUseCase {}
class MockVerifyVendorOtpUseCase extends Mock implements VerifyVendorOtpUseCase {}
class MockResendVendorOtpUseCase extends Mock implements ResendVendorOtpUseCase {}
class MockVendorLoginUseCase extends Mock implements VendorLoginUseCase {}
class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}
class MockKycPersonalDetailsUseCase extends Mock implements SubmitKycPersonalDetailsUseCase {}
class MockKycDocumentUseCase extends Mock implements UploadKycDocumentUseCase {}
class MockKycSelfieUseCase extends Mock implements UploadKycSelfieUseCase {}
class MockGetKycStatusUseCase extends Mock implements GetKycStatusUseCase {}
class MockCheckEmailExistsUseCase extends Mock implements CheckEmailExistsUseCase {}

void main() {
  late MockRegisterVendorUseCase registerVendor;
  late MockVerifyVendorOtpUseCase verifyVendorOtp;
  late MockResendVendorOtpUseCase resendVendorOtp;
  late MockCheckEmailExistsUseCase checkEmailExists;
  late AuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(const VendorRegisterParams(
      firstName: '', lastName: '', email: '', phone: '', password: '',
      shopName: '', shopSlug: '', businessName: '',
    ));
    registerFallbackValue(const VerifyVendorOtpParams(email: '', otp: ''));
  });

  setUp(() {
    registerVendor = MockRegisterVendorUseCase();
    verifyVendorOtp = MockVerifyVendorOtpUseCase();
    resendVendorOtp = MockResendVendorOtpUseCase();
    checkEmailExists = MockCheckEmailExistsUseCase();
    when(() => checkEmailExists(any())).thenAnswer((_) async => const Right(false));
    getIt.registerSingleton<CheckEmailExistsUseCase>(checkEmailExists);
    authBloc = AuthBloc(
      checkAuthStatus: MockCheckAuthStatusUseCase(),
      registerVendor: registerVendor,
      verifyVendorOtp: verifyVendorOtp,
      resendVendorOtp: resendVendorOtp,
      vendorLogin: MockVendorLoginUseCase(),
      forgotPassword: MockForgotPasswordUseCase(),
      logout: MockLogoutUseCase(),
      kycPersonalDetails: MockKycPersonalDetailsUseCase(),
      kycDocument: MockKycDocumentUseCase(),
      kycSelfie: MockKycSelfieUseCase(),
      getKycStatus: MockGetKycStatusUseCase(),
    );
  });

  tearDown(() {
    authBloc.close();
    getIt.reset();
  });

  Future<void> waitForBlocToSettle(WidgetTester tester) async {
    await tester.runAsync(
      () => authBloc.stream.firstWhere((s) => s is! AuthLoading),
    );
    await tester.pumpAndSettle();
  }

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: AppRoutes.register,
      routes: [
        GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterScreen()),
        GoRoute(
          path: AppRoutes.registerOtp,
          builder: (_, state) =>
              OtpVerificationScreen(args: state.extra as OtpScreenArgs),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, _) => const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> fillAndSubmitRegisterForm(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextFormField, 'First Name'), 'Acme');
    await tester.enterText(find.widgetWithText(TextFormField, 'Last Name'), 'Owner');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'owner@acme.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '9876543210');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'Secret@123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'Secret@123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 2: Business Details'), findsOneWidget,
        reason: 'personal details step should have validated and advanced');

    await tester.enterText(find.widgetWithText(TextFormField, 'Shop Name'), 'Acme Store');
    await tester.enterText(find.widgetWithText(TextFormField, 'Shop Slug'), 'acme-store');
    await tester.enterText(find.widgetWithText(TextFormField, 'Business Name'), 'Acme Pvt Ltd');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await waitForBlocToSettle(tester);
  }

  testWidgets(
    'register screen navigates to the OTP screen instead of straight into the app',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => registerVendor(any())).thenAnswer(
        (_) async => const Right(RegisterOtpEntity(
          email: 'owner@acme.com',
          message: 'OTP sent to your email. Verify it to complete vendor registration.',
        )),
      );

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await fillAndSubmitRegisterForm(tester);

      expect(find.text('Verify Email'), findsOneWidget);
      expect(find.textContaining('owner@acme.com'), findsWidgets);
      expect(find.widgetWithText(TextButton, 'Resend in 30s'), findsOneWidget);
    },
  );

  testWidgets(
    'verify button is disabled until 6 digits are entered, then shows an error on invalid OTP',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => registerVendor(any())).thenAnswer(
        (_) async => const Right(RegisterOtpEntity(
          email: 'owner@acme.com',
          message: 'OTP sent',
        )),
      );
      when(() => verifyVendorOtp(any())).thenAnswer(
        (_) async => const Left(ValidationFailure(message: 'Invalid OTP', fieldErrors: {})),
      );

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await fillAndSubmitRegisterForm(tester);

      final verifyButtonFinder = find.widgetWithText(ElevatedButton, 'Verify');
      expect(tester.widget<ElevatedButton>(verifyButtonFinder).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '000000');
      await tester.pumpAndSettle();

      expect(tester.widget<ElevatedButton>(verifyButtonFinder).onPressed, isNotNull);

      await tester.tap(verifyButtonFinder);
      await waitForBlocToSettle(tester);

      expect(find.text('Invalid OTP'), findsOneWidget);
      verify(() => verifyVendorOtp(const VerifyVendorOtpParams(
            email: 'owner@acme.com', otp: '000000',
          ))).called(1);
    },
  );

  testWidgets(
    'tapping Resend OTP after the cooldown calls the resend-otp endpoint and resets the timer',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => registerVendor(any())).thenAnswer(
        (_) async => const Right(RegisterOtpEntity(
          email: 'owner@acme.com',
          message: 'OTP sent',
        )),
      );
      when(() => resendVendorOtp(any())).thenAnswer(
        (_) async => const Right(RegisterOtpEntity(
          email: 'owner@acme.com',
          message: 'OTP resent',
        )),
      );

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await fillAndSubmitRegisterForm(tester);

      // Resend is disabled during the 30s cooldown.
      expect(
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'Resend in 30s')).onPressed,
        isNull,
      );

      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();

      final resendButtonFinder = find.widgetWithText(TextButton, 'Resend OTP');
      expect(tester.widget<TextButton>(resendButtonFinder).onPressed, isNotNull);

      await tester.tap(resendButtonFinder);
      await waitForBlocToSettle(tester);

      verify(() => resendVendorOtp('owner@acme.com')).called(1);
      expect(find.text('OTP resent to owner@acme.com'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Resend in 30s'), findsOneWidget);
    },
  );

  testWidgets(
    'verifying the OTP successfully redirects an authenticated user away from the public OTP route',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      const verifiedUser = UserEntity(
        id: '2', email: 'owner@acme.com', name: 'Acme Owner',
        role: 'vendor', kycStatus: 'pending',
      );

      when(() => registerVendor(any())).thenAnswer(
        (_) async => const Right(RegisterOtpEntity(
          email: 'owner@acme.com',
          message: 'OTP sent',
        )),
      );
      when(() => verifyVendorOtp(any())).thenAnswer(
        (_) async => const Right(verifiedUser),
      );

      var authState = const RouteAuthState.unauthenticated();
      final router = GoRouter(
        initialLocation: AppRoutes.register,
        redirect: (context, state) => RouteGuard.redirect(
          location: state.matchedLocation,
          authState: authState,
        ),
        routes: [
          GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterScreen()),
          GoRoute(
            path: AppRoutes.registerOtp,
            builder: (_, state) =>
                OtpVerificationScreen(args: state.extra as OtpScreenArgs),
          ),
          GoRoute(
            path: AppRoutes.vendorHome,
            builder: (_, _) => const Scaffold(body: Text('Dashboard')),
          ),
        ],
      );

      final app = BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              authState = const RouteAuthState.authenticated();
              router.refresh();
            }
          },
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      await fillAndSubmitRegisterForm(tester);

      await tester.enterText(find.byType(TextField), '942653');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Verify'));
      await waitForBlocToSettle(tester);

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Verify Email'), findsNothing);
    },
  );

  testWidgets(
    'shows a dialog offering to log in when the typed email already exists',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => checkEmailExists(any())).thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'nishant.vendor@yopmail.com',
      );
      // Move focus away from the email field to trigger the existence check.
      await tester.tap(find.widgetWithText(TextFormField, 'First Name'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      verify(() => checkEmailExists('nishant.vendor@yopmail.com')).called(1);
      expect(find.text('Account already exists'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Go to Login'));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    },
  );

  testWidgets(
    'does not show the dialog when the typed email does not exist',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => checkEmailExists(any())).thenAnswer((_) async => const Right(false));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'nishant.vendor2@yopmail.com',
      );
      await tester.tap(find.widgetWithText(TextFormField, 'First Name'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      verify(() => checkEmailExists('nishant.vendor2@yopmail.com')).called(1);
      expect(find.text('Account already exists'), findsNothing);
    },
  );
}
