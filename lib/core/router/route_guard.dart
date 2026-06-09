import 'app_routes.dart';

enum UserRole { buyer, vendor }

class RouteAuthState {
  final bool isAuthenticated;
  final UserRole? role;

  const RouteAuthState({required this.isAuthenticated, this.role});

  const RouteAuthState.unauthenticated()
      : isAuthenticated = false,
        role = null;
}

class RouteGuard {
  static String? redirect({
    required String location,
    required RouteAuthState authState,
  }) {
    final isPublic = AppRoutes.publicRoutes.any(
      (r) => location == r || location.startsWith(r),
    );

    if (!authState.isAuthenticated) {
      return isPublic ? null : AppRoutes.login;
    }

    // Already logged in — redirect away from public routes
    if (isPublic && location != AppRoutes.splash) {
      return authState.role == UserRole.vendor
          ? AppRoutes.vendorHome
          : AppRoutes.buyerHome;
    }

    // Block cross-role navigation
    if (location.startsWith('/vendor') && authState.role != UserRole.vendor) {
      return AppRoutes.buyerHome;
    }
    if (location.startsWith('/buyer') && authState.role != UserRole.buyer) {
      return AppRoutes.vendorHome;
    }

    return null;
  }
}
