import 'app_routes.dart';

enum UserRole { buyer, vendor }

class RouteAuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserRole? role;
  final bool isKycPending;

  const RouteAuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.role,
    this.isKycPending = false,
  });

  const RouteAuthState.loading()
    : isAuthenticated = false,
      isLoading = true,
      role = null,
      isKycPending = false;

  const RouteAuthState.unauthenticated()
    : isAuthenticated = false,
      isLoading = false,
      role = null,
      isKycPending = false;

  const RouteAuthState.authenticated({
    required this.role,
    this.isKycPending = false,
  }) : isAuthenticated = true,
       isLoading = false;
}

class RouteGuard {
  static String? redirect({
    required String location,
    required RouteAuthState authState,
  }) {
    // Stay on splash while auth is being determined; block all other routes.
    if (authState.isLoading) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    // Redirect away from splash once auth is known.
    if (location == AppRoutes.splash) {
      if (!authState.isAuthenticated) return AppRoutes.login;
      return authState.role == UserRole.vendor
          ? AppRoutes.home
          : AppRoutes.buyerHome;
    }

    final isPublic = AppRoutes.publicRoutes.any(
      (r) => location == r || location.startsWith(r),
    );

    if (!authState.isAuthenticated) {
      return isPublic ? null : AppRoutes.login;
    }

    // Vendor with pending KYC must complete KYC first
    if (authState.isKycPending &&
        authState.role == UserRole.vendor &&
        !location.startsWith(AppRoutes.registerKyc)) {
      return AppRoutes.registerKyc;
    }

    // Already logged in — redirect away from auth screens (but not from KYC if still pending)
    if (isPublic && location != AppRoutes.splash) {
      if (authState.isKycPending) return null;
      // return authState.role == UserRole.vendor
      //     ? AppRoutes.vendorHome
      //     : AppRoutes.home;
      return authState.role == UserRole.vendor
          ? AppRoutes.home
          : AppRoutes.home;
    }

    // Block cross-role navigation
    if (location.startsWith('/vendor') && authState.role != UserRole.vendor) {
      return AppRoutes.buyerHome;
    }
    if (location.startsWith('/buyer') && authState.role != UserRole.buyer) {
      // return AppRoutes.vendorHome;
      return AppRoutes.home;
    }

    return null;
  }
}
