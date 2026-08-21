import 'package:bingo_pay/features/edit_profile/presentation/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/account/presentation/cubit/account_cubit.dart';
import '../../features/account/presentation/screens/account_page.dart';
import '../../features/auctions/presentation/screens/auction_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/customer/shop/presentation/bloc/shop_bloc.dart';
import '../../features/customer/shop/presentation/bloc/shop_event.dart';
import '../../features/edit_profile/presentation/cubit/edit_profile_cubit.dart';
import '../../features/membershipNew/data/models/membership_plan_model.dart';
import '../../features/membershipNew/presentation/screens/membership_checkout_screen.dart';
import '../../features/membershipNew/presentation/screens/membership_dashbord.dart';
import '../../features/membershipNew/presentation/screens/membership_screen.dart';
import '../../features/membershipNew/presentation/screens/membership_success_screen.dart';
import '../../features/membershipNew/presentation/widgets/membership_checkout_args.dart';
import '../../features/notification/features/screens/notidication_screen.dart';
import '../../features/order_details/presentaion/screens/order_details_screen.dart';
import '../../features/orders/presentation/screens/my_orders_screen.dart';
import '../../features/scanner/presentation/screens/scanner_review_pay_screen.dart';
import '../../features/scanner/presentation/screens/transaction_success_screen.dart';
import '../../features/setting/features/screens/setting_screen.dart';
import '../widgets/buyer_shell_screen.dart';
import '../../features/customer/shop/presentation/screens/checkout_placeholder_screen.dart';
import '../../features/customer/profile/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_document_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_selfie_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sso_otp_verification_screen.dart';
import '../../features/auth/presentation/screens/sso_set_password_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/all_products_screen.dart';
import '../../features/on_boarding/presentation/screens/onboarding_screen.dart';
import '../../features/services/presentation/screens/all_services_screen.dart';
import '../../features/services/presentation/screens/service_detail_screen.dart';
import '../../features/orders/data/models/order_model.dart';
import '../../features/payment/presentation/screens/payment_success_screen.dart';
import '../../features/product_categories_details/presentation/screens/product_categories_screen.dart';
import '../../features/product_details/presentation/cubit/product_details_cubit.dart';
import '../../features/product_details/presentation/screens/product_details_screen.dart';
import '../../features/scanner/presentation/cubit/payment_cubit.dart';
import '../../features/scanner/presentation/screens/payment_screen.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/splash/presentaion/screens/splash_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../features/wallet/presentation/screens/wallet_screens.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../../features/help_support/presentation/screens/help_support_screen.dart';
import '../di/injection.dart';
import '../storage/preferences_service.dart';
import 'app_routes.dart';
import 'route_guard.dart';

@lazySingleton
class AppRouter {
  late final GoRouter router;
  RouteAuthState _authState = const RouteAuthState.loading();

  /// Splash minimum visible duration
  static const _minSplashDuration = Duration(milliseconds: 1500);
  final DateTime _startedAt = DateTime.now();

  // void markOnboardingSeen() {
  //   _authState = RouteAuthState(
  //     isAuthenticated: _authState.isAuthenticated,
  //     isLoading: _authState.isLoading,
  //     isKycPending: _authState.isKycPending,
  //     hasSeenOnboarding: true,
  //   );
  //   router.refresh();
  // }

  void markOnboardingSeen() {
    _authState = RouteAuthState(
      isAuthenticated: _authState.isAuthenticated,
      isLoading: false,
      isKycPending: _authState.isKycPending,
      hasSeenOnboarding: true,
    );
    router.refresh();
  }

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
          builder: (_, _) => const SplashScreen(),
        ),

        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, _) => OnboardingScreen(
            onFinish: () async {
              await getIt<PreferencesService>().setOnboardingSeen();
              getIt<AppRouter>().markOnboardingSeen();
            },
          ),
        ),

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
          path: AppRoutes.ssoLoginOtp,
          builder: (_, state) =>
              SsoOtpVerificationScreen(email: state.extra as String? ?? ''),
        ),
        GoRoute(
          path: AppRoutes.ssoSetPassword,
          builder: (_, state) =>
              SsoSetPasswordScreen(email: state.extra as String? ?? ''),
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
          path: AppRoutes.orderDetail,
          builder: (context, state) {
            debugPrint('ORDER DETAIL ROUTE HIT');

            final order = state.extra as OrderModel;

            return OrderDetailScreen(order: order);
          },
        ),

        GoRoute(
          path: AppRoutes.search,
          builder: (context, state) => BlocProvider(
            create: (_) => SearchCubit(),
            child: const SearchScreen(),
          ),
        ),

        // GoRoute(
        //   path: AppRoutes.productDetails,
        //   builder: (context, state) {
        //     final product = state.extra as ProductModel;
        //
        //     return BlocProvider(
        //       create: (_) => ProductDetailCubit()..loadProduct(product),
        //       child: const ProductDetailScreen(),
        //     );
        //   },
        // ),
        GoRoute(
          path: AppRoutes.productDetails,
          builder: (context, state) {
            final uuid = state.extra as String;
            return BlocProvider(
              create: (_) => ProductDetailCubit()..loadProduct(uuid),
              child: const ProductDetailScreen(),
            );
          },
        ),

        // Deep link routes for product sharing
        GoRoute(
          path: '/products/:id',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return BlocProvider(
              create: (_) => ProductDetailCubit()..loadProduct(productId),
              child: const ProductDetailScreen(),
            );
          },
        ),

        GoRoute(path: AppRoutes.cart, builder: (_, _) => const CartPage()),

        // GoRoute(
        //   path: AppRoutes.reviewPayment,
        //   builder: (context, state) {
        //     final data = state.extra as Map<String, dynamic>;
        //
        //     return BlocProvider(
        //       create: (_) => getIt<PaymentCubit>(),
        //       child: ReviewPaymentScreen(
        //         merchantName: data['merchantName'] ?? '',
        //         merchantEmail: data['merchantEmail'] ?? '',
        //       ),
        //     );
        //   },
        // ),

        GoRoute(
          path: AppRoutes.reviewPayment,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>? ?? const {};

            return BlocProvider(
              create: (_) => getIt<PaymentCubit>(),
              child: ReviewPaymentScreen(
                merchantName: data['merchantName'] ?? '',
                merchantEmail: data['merchantEmail'] ?? '',
              ),
            );
          },
        ),

        GoRoute(
          path: AppRoutes.paymentSuccess,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;

            return PaymentSuccessScreen();
          },
        ),

        GoRoute(
          path: AppRoutes.transferSuccess,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;

            return TransferScreen(data: data);
          },
        ),

        GoRoute(
          path: AppRoutes.buyerSettings,
          builder: (_, _) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.buyerNotifications,
          builder: (_, _) => const NotificationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.help,
          builder: (_, _) => const HelpSupportScreen(),
        ),

        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider<ShopBloc>(
              create: (_) => ShopBloc()..add(const ShopStarted()),
              child: BuyerShellScreen(location: state.uri.path, child: child),
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (_, _) => const HomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.scanner,
              builder: (context, state) => const ScannerScreen(),
            ),
            GoRoute(
              path: AppRoutes.buyerWishlist,
              builder: (_, _) => const WishlistScreen(),
            ),

            GoRoute(
              path: AppRoutes.editProfile,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<EditProfileCubit>(),
                child: const EditProfileScreen(),
              ),
            ),

            // GoRoute(
            //   path: AppRoutes.buyerDashboard,
            //   builder: (_, _) => BlocProvider<BuyerDashboardCubit>(
            //     create: (_) => BuyerDashboardCubit(),
            //     child: const BuyerDashboardScreen(),
            //   ),
            // ),
            GoRoute(
              path: AppRoutes.categories,
              builder: (_, _) => const CategoriesScreen(),
            ),
            GoRoute(
              path: AppRoutes.allProducts,
              builder: (_, _) => const AllProductsScreen(),
            ),
            GoRoute(
              path: AppRoutes.services,
              builder: (_, _) => const AllServicesScreen(),
            ),
            GoRoute(
              path: '/service-detail/:uuid',
              builder: (context, state) {
                final uuid = state.pathParameters['uuid'] ?? '';
                return ServiceDetailScreen(serviceUuid: uuid);
              },
            ),
            GoRoute(
              path: AppRoutes.productListing,
              builder: (context, state) => ProductListingScreen(
                categoryName: Uri.decodeComponent(
                  state.pathParameters['categoryName'] ?? '',
                ),
                categoryUuid: state.extra as String? ?? '',
              ),
            ),

            GoRoute(
              path: AppRoutes.orders,
              builder: (_, _) => const OrdersScreen(),
            ),

            GoRoute(
              path: AppRoutes.account,
              builder: (context, state) {
                return BlocProvider(
                  create: (_) => getIt<AccountCubit>(),
                  child: const AccountScreen(),
                );
              },
            ),

            GoRoute(
              path: AppRoutes.wallet,
              builder: (context, state) => BlocProvider(
                create: (_) => WalletCubit()..loadWallet(),
                child: const WalletScreen(),
              ),
            ),

            // GoRoute(
            //   path: AppRoutes.buyerCatalog,
            //   builder: (_, _) => const CatalogScreen(),
            // ),
            // GoRoute(
            //   path: AppRoutes.buyerSearch,
            //   builder: (context, state) => CatalogScreen(
            //     title: 'Search results',
            //     subtitle: 'Refine what you are looking for.',
            //     initialQuery: state.uri.queryParameters['q'] ?? '',
            //   ),
            // ),
            // GoRoute(
            //   path: AppRoutes.buyerCategory,
            //   builder: (context, state) => CategoryScreen(
            //     categorySlug: state.pathParameters['slug'] ?? '',
            //   ),
            // ),
            // GoRoute(
            //   path: AppRoutes.buyerCart,
            //   builder: (_, _) => const CartScreen(),
            // ),
            GoRoute(
              path: AppRoutes.buyerCheckout,
              builder: (_, _) => const CheckoutPlaceholderScreen(),
            ),
            GoRoute(
              path: AppRoutes.buyerTransactions,
              builder: (_, _) => const TransactionsScreen(),
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

            // ShellRoute ke BAHAR
            // GoRoute(
            //   path: AppRoutes.membership,
            //   name: 'membership',
            //   builder: (context, state) => const MembershipScreen(),
            // ),
            GoRoute(
              path: AppRoutes.membershipPlans,          // '/membership-plans'
              name: 'membershipPlans',
              builder: (context, state) =>
                  MembershipPlansScreen(preselectPlanUuid: state.extra as String?),
            ),
            GoRoute(
              path: AppRoutes.membershipCheckout,
              redirect: (context, state) =>
              state.extra is MembershipCheckoutArgs ? null : AppRoutes.membershipPlans,
              builder: (context, state) =>
                  MembershipCheckoutScreen(args: state.extra as MembershipCheckoutArgs),
            ),

            GoRoute(
              path: AppRoutes.membershipSuccess,
              redirect: (context, state) =>
              state.extra is MembershipCheckoutArgs ? null : AppRoutes.membershipPlans,
              builder: (context, state) =>
                  MembershipSuccessScreen(args: state.extra as MembershipCheckoutArgs),
            ),

            GoRoute(
              path: AppRoutes.buyerAddresses,
              builder: (_, _) => const _PlaceholderPage('Addresses'),
            ),
            GoRoute(
              path: AppRoutes.buyerPayments,
              builder: (_, _) => const _PlaceholderPage('Payment Methods'),
            ),

            GoRoute(
              path: AppRoutes.auctionScreen,
              builder: (_, _) => const AuctionScreen(),
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

  // void updateAuthState(RouteAuthState state) {
  //   _authState = state;
  //   router.refresh();
  // }
  Future<void> updateAuthState(RouteAuthState state) async {
    debugPrint(
      'AUTH → auth=${state.isAuthenticated} '
      'loading=${state.isLoading} '
      'onboarding=${state.hasSeenOnboarding} '
      'kyc=${state.isKycPending}',
    );
    // Sirf pehli baar (loading -> resolved) wait karo
    if (_authState.isLoading && !state.isLoading) {
      final elapsed = DateTime.now().difference(_startedAt);
      final remaining = _minSplashDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }
    }

    _authState = state;
    router.refresh();
  }
}

// class _SplashPage extends StatelessWidget {
//   const _SplashPage();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(name)));
  }
}
