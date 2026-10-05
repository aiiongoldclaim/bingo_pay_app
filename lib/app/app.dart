import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intro/intro.dart';
import 'package:sizer/sizer.dart';

import '../core/di/injection.dart';
import '../core/network/connectivity_service.dart';
import '../core/router/app_router.dart';
import '../core/router/route_guard.dart';
import '../core/storage/preferences_service.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive_utils.dart';
import '../core/widgets/no_internet_screen.dart';
import '../features/auctions/presentation/cubit/auction_cubit.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/address/presentation/cubit/address_cubit.dart';
import '../features/bookings/presentation/cubit/booking_cubit.dart';
import '../features/cart/presentation/cubit/cart_cubit.dart';
import '../features/chat/presentation/cubit/chat_cubit.dart';
import '../features/health/presentation/cubit/health_cubit.dart';
import '../features/health/presentation/cubit/health_state.dart';
import '../features/health/presentation/widgets/server_down_screen.dart';
import '../features/help_support/presentation/cubit/support_ticket_cubit.dart';
import '../features/services/presentation/cubit/services_cubit.dart';
import '../features/setting/features/cubit/settings_cubit.dart';
import '../features/wishlist/presentation/cubit/wishlist_cubit.dart';
import '../core/cubit/in_app_review_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = getIt<AppRouter>();
  final _connectivity = getIt<ConnectivityService>();
  final _cartCubit = getIt<CartCubit>();
  final _wishlistCubit = getIt<WishlistCubit>();
  bool _authDetermined = false;

  final _prefs = getIt<PreferencesService>();
  late final bool _onboardingSeen;

  // Home screen's product tour is registered here, at the root of the
  // widget tree, so `Intro.of(context)` can be resolved from any screen.
  final _introController = IntroController(stepCount: 6);

  final _healthCubit = getIt<HealthCubit>();
  StreamSubscription<bool>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _onboardingSeen = _prefs.isOnboardingSeen();

    // Check the backend as soon as the app starts, and re-check whenever the
    // device comes back online after a failed check.
    _healthCubit.checkHealth();
    _connectivitySub = _connectivity.isConnected.listen((connected) {
      if (connected && _healthCubit.state is HealthDown) {
        _healthCubit.checkHealth();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _healthCubit.close();
    super.dispose();
  }

  // void _onAuthStateChanged(BuildContext context, AuthState state) {
  //   if (state is AuthLoading) {
  //     if (!_authDetermined) {
  //       _router.updateAuthState(const RouteAuthState.loading());
  //     }
  //   } else if (state is AuthAuthenticated) {
  //     _authDetermined = true;
  //     _router.updateAuthState(const RouteAuthState.authenticated());
  //     // Warm the cart in the background so "already in cart" checks and
  //     // add-to-cart elsewhere don't need to wait on a fresh fetch.
  //     _cartCubit.loadCart();
  //   } else if (state is AuthUnauthenticated || state is AuthLoggedOut) {
  //     _authDetermined = true;
  //     _router.updateAuthState(const RouteAuthState.unauthenticated());
  //   }
  // }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      if (!_authDetermined) {
        unawaited(_router.updateAuthState(const RouteAuthState.loading()));
      }
    } else if (state is AuthAuthenticated) {
      _authDetermined = true;
      unawaited(_wishlistCubit.loadForUser(state.user.id));

      final onboardingSeen = _prefs.isOnboardingSeen();

      debugPrint(
        'AUTH → Authenticated '
            'onboardingSeen=$onboardingSeen',
      );

      unawaited(
        _router.updateAuthState(
          RouteAuthState.authenticated(
            isKycPending: false,
            // isKycPending: state.user.kycStatus != 'approved',
            hasSeenOnboarding: onboardingSeen,
          ),
        ),
      );
      _cartCubit.loadCart();
    } else if (state is SsoSetPasswordRequired) {
      _authDetermined = true;
      unawaited(
        _router.updateAuthState(
          const RouteAuthState.unauthenticated(hasSeenOnboarding: false),
        ),
      );
    } else if (state is AuthUnauthenticated || state is AuthLoggedOut) {
      _authDetermined = true;
      _wishlistCubit.clearForLogout();
      _cartCubit.clearForLogout();
      unawaited(
        _router.updateAuthState(
          RouteAuthState.unauthenticated(hasSeenOnboarding: _onboardingSeen),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) =>
              getIt<AuthBloc>()..add(const CheckAuthStatusRequested()),
        ),
        BlocProvider<CartCubit>.value(value: _cartCubit),
        BlocProvider<AddressCubit>(create: (_) => getIt<AddressCubit>()),
        BlocProvider<WishlistCubit>.value(value: _wishlistCubit),
        BlocProvider<AuctionCubit>(create: (_) => getIt<AuctionCubit>()),
        BlocProvider<BookingCubit>(create: (_) => getIt<BookingCubit>()),
        BlocProvider<AvailabilityCubit>(create: (_) => getIt<AvailabilityCubit>()),
        BlocProvider<InAppReviewCubit>(create: (_) => getIt<InAppReviewCubit>()),
        BlocProvider<ChatCubit>(create: (_) => getIt<ChatCubit>()),
        BlocProvider<SupportTicketCubit>(create: (_) => getIt<SupportTicketCubit>()),
        BlocProvider<SettingsCubit>(create: (_) => getIt<SettingsCubit>()),
        BlocProvider<HealthCubit>.value(value: _healthCubit),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: _onAuthStateChanged,
        child: Sizer(
          builder: (context, orientation, deviceType) {
            ResponsiveUtils.setDeviceType(context);
            final mq = MediaQuery.of(context);
            debugPrint(
              'size: ${mq.size}, shortestSide: ${mq.size.shortestSide}, dpr: ${mq.devicePixelRatio}',
            );
            // return StreamBuilder<bool>(
            //   stream: _connectivity.isConnected,
            //   builder: (context, snapshot) {
            //     final isConnected = snapshot.data ?? true;
            //     return MaterialApp.router(
            //       title: 'Vaults',
            //       theme: AppTheme.light,
            //       themeMode: ThemeMode.system,
            //       debugShowCheckedModeBanner: false,
            //       darkTheme: AppTheme.dark,
            //       routerConfig: _router.router,
            //       builder: (context, child) {
            //         return Stack(
            //           children: [
            //             child ?? const SizedBox.shrink(),
            //             if (!isConnected) const NoInternetScreen(),
            //           ],
            //         );
            //       },
            //     );
            //   },
            // );
            return MaterialApp.router(
              title: 'Vaults',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.system,
              debugShowCheckedModeBanner: false,
              routerConfig: _router.router,
              builder: (context, child) {
                return Intro(
                  controller: _introController,
                  child: Stack(
                    children: [
                      child ?? const SizedBox.shrink(),
                      // Below the no-internet overlay so being offline
                      // takes priority over "server down".
                      BlocBuilder<HealthCubit, HealthState>(
                        builder: (context, state) {
                          final showServerDown = state is HealthDown ||
                              (state is HealthChecking && state.isRetry);
                          return showServerDown
                              ? const ServerDownScreen()
                              : const SizedBox.shrink();
                        },
                      ),
                      StreamBuilder<bool>(
                        stream: _connectivity.isConnected,
                        builder: (context, snapshot) {
                          final isConnected = snapshot.data ?? true;
                          return isConnected
                              ? const SizedBox.shrink()
                              : const NoInternetScreen();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
