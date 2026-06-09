import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/router/route_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteGuard.redirect', () {
    test('unauthenticated user on protected route redirects to login', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.buyerHome,
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

    test('authenticated buyer on vendor route redirects to buyer home', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.vendorHome,
        authState: const RouteAuthState(
          isAuthenticated: true,
          role: UserRole.buyer,
        ),
      );
      expect(result, AppRoutes.buyerHome);
    });

    test('authenticated vendor on vendor route is allowed', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.vendorHome,
        authState: const RouteAuthState(
          isAuthenticated: true,
          role: UserRole.vendor,
        ),
      );
      expect(result, isNull);
    });

    test('authenticated user on login page is redirected to their home', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.login,
        authState: const RouteAuthState(
          isAuthenticated: true,
          role: UserRole.buyer,
        ),
      );
      expect(result, AppRoutes.buyerHome);
    });
  });
}
