import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/router/route_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteGuard.redirect', () {
    test('loading state stays on splash', () {
      expect(
        RouteGuard.redirect(
          location: AppRoutes.splash,
          authState: const RouteAuthState.loading(),
        ),
        isNull,
      );
    });

    test('loading state redirects non-splash to splash', () {
      expect(
        RouteGuard.redirect(
          location: AppRoutes.login,
          authState: const RouteAuthState.loading(),
        ),
        AppRoutes.splash,
      );
    });

    test('unauthenticated user on splash redirects to login', () {
      expect(
        RouteGuard.redirect(
          location: AppRoutes.splash,
          authState: const RouteAuthState.unauthenticated(),
        ),
        AppRoutes.login,
      );
    });

    test('authenticated user on splash redirects to home', () {
      expect(
        RouteGuard.redirect(
          location: AppRoutes.splash,
          authState: const RouteAuthState.authenticated(),
        ),
        AppRoutes.home,
      );
    });

    test('unauthenticated user on protected route redirects to login', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.home,
        authState: const RouteAuthState.unauthenticated(),
      );
      expect(result, AppRoutes.login);
    });

    test('unauthenticated user on public route is allowed', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.login,
        authState: const RouteAuthState.unauthenticated(),
      );
      expect(result, isNull);
    });

    test('authenticated user on login page is redirected home', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.login,
        authState: const RouteAuthState.authenticated(),
      );
      expect(result, AppRoutes.home);
    });

    test('authenticated user on a protected route is allowed', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.home,
        authState: const RouteAuthState.authenticated(),
      );
      expect(result, isNull);
    });
  });
}
