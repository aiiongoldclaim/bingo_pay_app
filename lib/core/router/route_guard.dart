import 'app_routes.dart';

class RouteAuthState {
  final bool isAuthenticated;
  final bool isLoading;

  const RouteAuthState({
    required this.isAuthenticated,
    this.isLoading = false,
  });

  const RouteAuthState.loading() : isAuthenticated = false, isLoading = true;

  const RouteAuthState.unauthenticated()
    : isAuthenticated = false,
      isLoading = false;

  const RouteAuthState.authenticated() : isAuthenticated = true, isLoading = false;
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
      return authState.isAuthenticated ? AppRoutes.home : AppRoutes.login;
    }

    final isPublic = AppRoutes.publicRoutes.any(
      (r) => location == r || location.startsWith(r),
    );

    if (!authState.isAuthenticated) {
      return isPublic ? null : AppRoutes.login;
    }

    // Already logged in — redirect away from auth screens.
    if (isPublic && location != AppRoutes.splash) {
      return AppRoutes.home;
    }

    return null;
  }
}
