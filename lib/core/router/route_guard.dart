import 'app_routes.dart';

enum UserRole { buyer, vendor }

class RouteAuthState {
  final bool isAuthenticated;
  final UserRole? role;
  final bool isKycPending;

  const RouteAuthState({
    required this.isAuthenticated,
    this.role,
    this.isKycPending = false,
  });

  const RouteAuthState.unauthenticated()
      : isAuthenticated = false,
        role = null,
        isKycPending = false;

  const RouteAuthState.authenticated({
    required this.role,
    this.isKycPending = false,
  }) : isAuthenticated = true;
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

    // Vendor with pending KYC must complete KYC first
    if (authState.isKycPending &&
        authState.role == UserRole.vendor &&
        location != AppRoutes.registerKyc) {
      return AppRoutes.registerKyc;
    }

    // Already logged in — redirect away from auth screens (but not from KYC if still pending)
    if (isPublic && location != AppRoutes.splash) {
      if (authState.isKycPending) return null;
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
