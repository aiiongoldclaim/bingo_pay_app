import 'app_routes.dart';

class RouteAuthState {
  final bool isAuthenticated;
  final bool isLoading;

  /// Vendor KYB status ('none'|'inprogress'|'approved'|'rejected'|'recheck'
  /// |'expired'), only meaningful when [isAuthenticated] is true.
  final String kybStatus;

  const RouteAuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.kybStatus = 'approved',
  });

  const RouteAuthState.loading()
      : isAuthenticated = false,
        isLoading = true,
        kybStatus = '';

  const RouteAuthState.unauthenticated()
      : isAuthenticated = false,
        isLoading = false,
        kybStatus = '';

  const RouteAuthState.authenticated({this.kybStatus = 'approved'})
      : isAuthenticated = true,
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

    // A vendor whose KYB review is still in progress has nothing to do yet
    // (docs already submitted) — treat them as blocked, same as logged out,
    // until the backend flips them to approved/rejected/recheck/expired.
    final blockedByKyb =
        authState.isAuthenticated && authState.kybStatus == 'inprogress';
    final effectivelyAuthenticated = authState.isAuthenticated && !blockedByKyb;

    // Redirect away from splash once auth is known.
    if (location == AppRoutes.splash) {
      if (!effectivelyAuthenticated) return AppRoutes.login;
      return authState.kybStatus == 'approved'
          ? AppRoutes.vendorHome
          : AppRoutes.registerKyc;
    }

    final isPublic = AppRoutes.publicRoutes.any(
      (r) => location == r || location.startsWith(r),
    );

    if (!effectivelyAuthenticated) {
      return isPublic ? null : AppRoutes.login;
    }

    // The register → OTP → set-password → KYC onboarding chain (all nested
    // under /register) must stay reachable once authenticated — those
    // screens navigate on explicitly once auth completes. This also covers
    // GoRouter reporting a stale /register base location on refresh() while
    // the user is actually on a route pushed on top of it.
    if (location.startsWith(AppRoutes.register)) return null;

    // Already logged in — redirect away from auth screens. Only an approved
    // vendor may land on the dashboard; anyone else still needs KYC.
    if (isPublic && location != AppRoutes.splash) {
      return authState.kybStatus == 'approved'
          ? AppRoutes.vendorHome
          : AppRoutes.registerKyc;
    }

    // Non-approved vendors can't reach protected vendor routes even via a
    // direct/deep link — the backend would 403 anyway, so bounce to KYC.
    if (authState.kybStatus != 'approved') {
      return AppRoutes.registerKyc;
    }

    return null;
  }
}
