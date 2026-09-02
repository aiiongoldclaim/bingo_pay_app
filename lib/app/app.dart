import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../features/services/presentation/cubit/services_cubit.dart';
import '../features/wishlist/presentation/cubit/wishlist_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = getIt<AppRouter>();
  final _connectivity = getIt<ConnectivityService>();
  final _cartCubit = getIt<CartCubit>();
  bool _authDetermined = false;

  final _prefs = getIt<PreferencesService>();
  late final bool _onboardingSeen;

  @override
  void initState() {
    super.initState();
    _onboardingSeen = _prefs.isOnboardingSeen();
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
            hasSeenOnboarding: _onboardingSeen,
          ),
        ),
      );
      _cartCubit.loadCart();
    } else if (state is AuthUnauthenticated || state is AuthLoggedOut) {
      _authDetermined = true;
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
        BlocProvider<WishlistCubit>(create: (_) => getIt<WishlistCubit>()),
        BlocProvider<AuctionCubit>(create: (_) => getIt<AuctionCubit>()),
        BlocProvider<BookingCubit>(create: (_) => getIt<BookingCubit>()),
        BlocProvider<AvailabilityCubit>(create: (_) => getIt<AvailabilityCubit>()),
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
                return Stack(
                  children: [
                    child ?? const SizedBox.shrink(),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
