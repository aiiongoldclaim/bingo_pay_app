import 'app_routes.dart';

class RouteAuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isKycPending;
  final bool hasSeenOnboarding;

  const RouteAuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.isKycPending = false,
    this.hasSeenOnboarding = true,
  });

  const RouteAuthState.loading()
    : isAuthenticated = false,
      isLoading = true,
      isKycPending = false,
      hasSeenOnboarding = true;

  const RouteAuthState.unauthenticated({this.hasSeenOnboarding = true})
    : isAuthenticated = false,
      isLoading = false,
      isKycPending = false;

  const RouteAuthState.authenticated({
    this.isKycPending = false,
    this.hasSeenOnboarding = true,
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

    if (!authState.hasSeenOnboarding && !authState.isAuthenticated) {
      return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
    }

    if (location == AppRoutes.onboarding) {
      return authState.isAuthenticated ? AppRoutes.home : AppRoutes.login;
    }

    // Redirect away from splash once auth is known.
    if (location == AppRoutes.splash) {
      if (!authState.isAuthenticated) return AppRoutes.login;
      return AppRoutes.home;
    }

    final isPublic = AppRoutes.publicRoutes.any(
      (r) => location == r || location.startsWith(r),
    );

    if (!authState.isAuthenticated) {
      return isPublic ? null : AppRoutes.login;
    }

    // Pending KYC must be completed first
    if (authState.isKycPending && !location.startsWith(AppRoutes.registerKyc)) {
      return AppRoutes.registerKyc;
    }

    // Already logged in — redirect away from auth screens (but not from KYC if still pending)
    if (isPublic && location != AppRoutes.splash) {
      if (authState.isKycPending) return null;
      return AppRoutes.home;
    }

    return null;
  }
}
