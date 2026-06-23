import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/customer/shop/presentation/bloc/shop_bloc.dart';
import '../../features/customer/shop/presentation/bloc/shop_event.dart';
import '../../features/customer/shop/presentation/screens/buyer_home_screen.dart';
import '../../features/customer/shop/presentation/screens/buyer_shell_screen.dart';
import '../../features/customer/shop/presentation/screens/cart_screen.dart';
import '../../features/customer/shop/presentation/screens/catalog_screen.dart';
import '../../features/customer/shop/presentation/screens/category_screen.dart';
import '../../features/customer/shop/presentation/screens/checkout_placeholder_screen.dart';
import '../../features/customer/shop/presentation/screens/product_detail_screen.dart';
import '../../features/customer/dashboard/presentation/cubit/buyer_dashboard_cubit.dart';
import '../../features/customer/dashboard/presentation/screens/buyer_dashboard_screen.dart';
import '../../features/customer/profile/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_document_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_selfie_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/dashboard/presentation/widgets/home_bottom_nav.dart';
import 'app_routes.dart';
import 'route_guard.dart';

@lazySingleton
class AppRouter {
  late final GoRouter router;
  RouteAuthState _authState = const RouteAuthState.loading();

  AppRouter() {
    router = GoRouter(
      initialLocation: AppRoutes.home,
      redirect: (context, state) => RouteGuard.redirect(
        location: state.matchedLocation,
        authState: _authState,
      ),
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (_, _) => const _SplashPage()),
        GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
        // GoRoute(path: AppRoutes.login, builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, _) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerOtp,
          builder: (_, state) =>
              OtpVerificationScreen(email: state.extra as String? ?? ''),
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

        GoRoute(
          path: AppRoutes.buyerProductDetail,
          builder: (context, state) =>
              ProductDetailScreen(productId: state.pathParameters['id'] ?? ''),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider<ShopBloc>(
              create: (_) => ShopBloc()..add(const ShopStarted()),
              child: BuyerShellScreen(child: child, location: state.uri.path),
            );
          },
          routes: [
            // GoRoute(
            //   path: AppRoutes.buyerHome,
            //   builder: (_, _) => const BuyerHomeScreen(),
            // ),
            GoRoute(
              path: AppRoutes.home,
              builder: (_, _) => const HomeScreen(),
            ),

            GoRoute(
              path: AppRoutes.buyerDashboard,
              builder: (_, _) => BlocProvider<BuyerDashboardCubit>(
                create: (_) => BuyerDashboardCubit(),
                child: const BuyerDashboardScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.buyerCatalog,
              builder: (_, _) => const CatalogScreen(),
            ),
            GoRoute(
              path: AppRoutes.buyerSearch,
              builder: (context, state) => CatalogScreen(
                title: 'Search results',
                subtitle: 'Refine what you are looking for.',
                initialQuery: state.uri.queryParameters['q'] ?? '',
              ),
            ),
            GoRoute(
              path: AppRoutes.buyerCategory,
              builder: (context, state) => CategoryScreen(
                categorySlug: state.pathParameters['slug'] ?? '',
              ),
            ),
            GoRoute(
              path: AppRoutes.buyerProductDetail,
              builder: (context, state) => ProductDetailScreen(
                productId: state.pathParameters['id'] ?? '',
              ),
            ),
            GoRoute(
              path: AppRoutes.buyerCart,
              builder: (_, _) => const CartScreen(),
            ),
            GoRoute(
              path: AppRoutes.buyerCheckout,
              builder: (_, _) => const CheckoutPlaceholderScreen(),
            ),
            GoRoute(
              path: AppRoutes.buyerTransactions,
              builder: (_, _) => const _PlaceholderPage('Transactions'),
            ),
            GoRoute(
              path: AppRoutes.buyerTransactionDetail,
              builder: (context, state) =>
                  _PlaceholderPage('Order ${state.pathParameters['id'] ?? ''}'),
            ),
            GoRoute(
              path: AppRoutes.buyerProfile,
              builder: (_, _) => const ProfileScreen(),
            ),
            GoRoute(
              path: AppRoutes.buyerSettings,
              builder: (_, _) => const _PlaceholderPage('Settings'),
            ),
            GoRoute(
              path: AppRoutes.buyerNotifications,
              builder: (_, _) => const _PlaceholderPage('Notifications'),
            ),
            GoRoute(
              path: AppRoutes.buyerWishlist,
              builder: (_, _) => const _PlaceholderPage('Wishlist'),
            ),
            GoRoute(
              path: AppRoutes.buyerAddresses,
              builder: (_, _) => const _PlaceholderPage('Addresses'),
            ),
            GoRoute(
              path: AppRoutes.buyerPayments,
              builder: (_, _) => const _PlaceholderPage('Payment Methods'),
            ),
          ],
        ),
        GoRoute(
          path: '/vendor',
          builder: (_, _) => const _PlaceholderPage('Vendor Shell'),
          routes: [
            GoRoute(
              path: 'home',
              builder: (_, _) => const _PlaceholderPage('Vendor Home'),
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
