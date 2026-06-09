import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_document_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_selfie_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import 'app_routes.dart';
import 'route_guard.dart';

@lazySingleton
class AppRouter {
  late final GoRouter router;
  RouteAuthState _authState = const RouteAuthState.unauthenticated();

  AppRouter() {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) => RouteGuard.redirect(
        location: state.matchedLocation,
        authState: _authState,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, _) => const _SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, _) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, _) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerKyc,
          builder: (_, _) => const KycScreen(),
        ),
        GoRoute(
          path: AppRoutes.kycDocument,
          builder: (_, _) => const KycDocumentScreen(),
        ),
        GoRoute(
          path: AppRoutes.kycSelfie,
          builder: (_, _) => const KycSelfieScreen(),
        ),
        GoRoute(
          path: '/buyer',
          builder: (_, _) => const _PlaceholderPage('Buyer Shell'),
          routes: [
            GoRoute(
              path: 'home',
              builder: (_, _) => const _PlaceholderPage('Buyer Home'),
            ),
          ],
        ),
        GoRoute(
          path: '/vendor',
          builder: (_, _) => const _PlaceholderPage('Vendor Shell'),
          routes: [
            GoRoute(
              path: 'home',
              builder: (_, _) => const _PlaceholderPage('Vendor Home'),
            ),
          ],
        ),
      ],
    );
  }

  void updateAuthState(RouteAuthState state) {
    _authState = state;
    router.refresh();
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(name)));
  }
}
