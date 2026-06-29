// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:injectable/injectable.dart';
// import '../../features/auth/presentation/screens/forgot_password_screen.dart';
// import '../../features/auth/presentation/screens/kyc/kyc_document_screen.dart';
// import '../../features/auth/presentation/screens/kyc/kyc_screen.dart';
// import '../../features/auth/presentation/screens/kyc/kyc_selfie_screen.dart';
// import '../../features/auth/presentation/screens/login_screen.dart';
// import '../../features/auth/presentation/screens/register_screen.dart';
// import 'app_routes.dart';
// import 'route_guard.dart';

// @lazySingleton
// class AppRouter {
//   late final GoRouter router;
//   RouteAuthState _authState = const RouteAuthState.loading();

//   AppRouter() {
//     router = GoRouter(
//       initialLocation: AppRoutes.splash,
//       redirect: (context, state) => RouteGuard.redirect(
//         location: state.matchedLocation,
//         authState: _authState,
//       ),
//       routes: [
//         GoRoute(path: AppRoutes.splash, builder: (_, _) => const _SplashPage()),
//         GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
//         GoRoute(
//           path: AppRoutes.register,
//           builder: (_, _) => const RegisterScreen(),
//         ),
//         GoRoute(
//           path: AppRoutes.forgotPassword,
//           builder: (_, _) => const ForgotPasswordScreen(),
//         ),
//         GoRoute(
//           path: AppRoutes.registerKyc,
//           builder: (_, _) => const KycScreen(),
//         ),
//         GoRoute(
//           path: AppRoutes.kycDocument,
//           builder: (_, _) => const KycDocumentScreen(),
//         ),
//         GoRoute(
//           path: AppRoutes.kycSelfie,
//           builder: (_, _) => const KycSelfieScreen(),
//         ),
//         GoRoute(
//           path: '/vendor',
//           builder: (_, _) => const _PlaceholderPage('Vendor Shell'),
//           routes: [
//             GoRoute(
//               path: 'home',
//               builder: (_, _) => const _PlaceholderPage('Vendor Homge'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   void updateAuthState(RouteAuthState state) {
//     _authState = state;
//     router.refresh();
//   }
// }

// class _SplashPage extends StatelessWidget {
//   const _SplashPage();

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

// class _PlaceholderPage extends StatelessWidget {
//   final String name;
//   const _PlaceholderPage(this.name);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Text(name)));
//   }
// }

// import 'package:bingo_pay/features/dashboard/presentation/screen/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:go_router/go_router.dart';
// import 'package:injectable/injectable.dart';
// import '../../features/auth/presentation/screens/forgot_password_screen.dart';
// import '../../features/auth/presentation/screens/kyc/kyc_document_screen.dart';
// import '../../features/auth/presentation/screens/kyc/kyc_screen.dart';
// import '../../features/auth/presentation/screens/kyc/kyc_selfie_screen.dart';
// import '../../features/auth/presentation/screens/login_screen.dart';
// import '../../features/auth/presentation/screens/register_screen.dart';
// import '../storage/secure_storage_service.dart';
// import 'app_routes.dart';
// import 'route_guard.dart';

// @lazySingleton
// class AppRouter {
//   late final GoRouter router;
//   RouteAuthState _authState = const RouteAuthState.loading();

//   AppRouter() {
//     router = GoRouter(
//       initialLocation: AppRoutes.splash,
//       redirect: (context, state) => RouteGuard.redirect(
//         location: state.matchedLocation,
//         authState: _authState,
//       ),
//       routes: [
//         GoRoute(
//           path: AppRoutes.splash,
//           builder: (_, _) => _SplashPage(onCheckAuth: _checkInitialAuth),
//         ),
//         GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
//         GoRoute(
//           path: AppRoutes.register,
//           builder: (_, _) => const RegisterScreen(),
//         ),
//         GoRoute(
//           path: AppRoutes.forgotPassword,
//           builder: (_, _) => const ForgotPasswordScreen(),
//         ),
//         GoRoute(
//           path: AppRoutes.registerKyc,
//           builder: (_, _) => const KycScreen(),
//         ),
//         GoRoute(
//           path: AppRoutes.kycDocument,
//           builder: (_, _) => const KycDocumentScreen(),
//         ),
//         GoRoute(
//           path: AppRoutes.kycSelfie,
//           builder: (_, _) => const KycSelfieScreen(),
//         ),
//         GoRoute(
//           path: '/vendor',
//           builder: (_, _) => const DashboardScreen(navigationShell: null,),
//           routes: [
//             GoRoute(
//               path: 'home',
//               builder: (_, _) => const _PlaceholderPage('Vendor Home'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   void updateAuthState(RouteAuthState state) {
//     _authState = state;
//     router.refresh();
//   }

//   Future<void> _checkInitialAuth() async {
//     final secureStorage = GetIt.instance<SecureStorageService>();
//     final hasToken = await secureStorage.hasAccessToken();

//     // TODO: agar tumhare paas KYC pending status check karne ka
//     // koi API/local flag hai, yahan use karke isKycPending pass karo.
//     updateAuthState(
//       hasToken
//           ? const RouteAuthState.authenticated()
//           : const RouteAuthState.unauthenticated(),
//     );
//   }
// }

// class _SplashPage extends StatefulWidget {
//   final Future<void> Function() onCheckAuth;
//   const _SplashPage({required this.onCheckAuth});

//   @override
//   State<_SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<_SplashPage> {
//   @override
//   void initState() {
//     super.initState();
//     widget.onCheckAuth();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

// class _PlaceholderPage extends StatelessWidget {
//   final String name;
//   const _PlaceholderPage(this.name);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Text(name)));
//   }
// }

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_document_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_selfie_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screen/dashboard_screen.dart';

import '../../features/dashboard/presentation/screen/vendor_shell.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/products/presentation/screens/add_product_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/transactions/presentation/screens/add_order_screen.dart';
import '../../features/transactions/presentation/screens/transaction_screen.dart';
import '../storage/secure_storage_service.dart';
import 'app_routes.dart';
import 'route_guard.dart';

@lazySingleton
class AppRouter {
  late final GoRouter router;
  RouteAuthState _authState = const RouteAuthState.loading();

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
          builder: (_, _) => _SplashPage(onCheckAuth: _checkInitialAuth),
        ),
        GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, _) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerOtp,
          builder: (_, state) =>
              OtpVerificationScreen(args: state.extra as OtpScreenArgs),
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

        // Vendor shell with bottom nav — each branch keeps its own stack
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              VendorShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.vendorHome,
                  builder: (_, _) => const DashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.vendorProducts,
                  builder: (_, _) => const ProductsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.vendorTransactions,
                  builder: (_, _) => const TransactionScreen(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => _PlaceholderPage(
                        'Transaction ${state.pathParameters['id']}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.vendorMore,
                  builder: (_, _) => const MoreScreen(),
                ),
              ],
            ),
          ],
        ),

        // Add/edit product stays outside bottom-nav shell (pushed on top, full-screen)
        GoRoute(
          path: AppRoutes.vendorProductCreate,
          builder: (_, _) => const AddProductScreen(),
        ),
        GoRoute(
          path: AppRoutes.vendorProductDetail,
          builder: (context, state) =>
              ProductDetailScreen(uuid: state.pathParameters['id']!),
        ),
        GoRoute(
          path: AppRoutes.vendorProductEdit,
          builder: (context, state) =>
              AddProductScreen(productId: state.pathParameters['id']!),
        ),

        // Add order stays outside bottom-nav shell (pushed on top, full-screen)
        GoRoute(
          path: AppRoutes.vendorOrderCreate,
          builder: (_, _) => const AddOrderScreen(),
        ),

        // Invoices stays outside bottom-nav shell (pushed on top, full-screen)
        GoRoute(
          path: AppRoutes.vendorInvoices,
          builder: (_, _) => const _PlaceholderPage('Invoices'),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  _PlaceholderPage('Invoice ${state.pathParameters['id']}'),
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

  Future<void> _checkInitialAuth() async {
    final secureStorage = GetIt.instance<SecureStorageService>();
    final hasToken = await secureStorage.hasAccessToken();

    updateAuthState(
      hasToken
          ? const RouteAuthState.authenticated()
          : const RouteAuthState.unauthenticated(),
    );
  }
}

class _SplashPage extends StatefulWidget {
  final Future<void> Function() onCheckAuth;
  const _SplashPage({required this.onCheckAuth});

  @override
  State<_SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<_SplashPage> {
  @override
  void initState() {
    super.initState();
    widget.onCheckAuth();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
