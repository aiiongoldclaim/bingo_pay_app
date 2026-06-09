import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
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
          builder: (_, __) => const _SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const _PlaceholderPage('Login'),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, __) => const _PlaceholderPage('Register'),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const _PlaceholderPage('Forgot Password'),
        ),
        GoRoute(
          path: '/buyer',
          builder: (_, __) => const _PlaceholderPage('Buyer Shell'),
          routes: [
            GoRoute(
              path: 'home',
              builder: (_, __) => const _PlaceholderPage('Buyer Home'),
            ),
          ],
        ),
        GoRoute(
          path: '/vendor',
          builder: (_, __) => const _PlaceholderPage('Vendor Shell'),
          routes: [
            GoRoute(
              path: 'home',
              builder: (_, __) => const _PlaceholderPage('Vendor Home'),
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
