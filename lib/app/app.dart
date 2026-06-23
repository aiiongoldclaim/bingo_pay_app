import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../core/di/injection.dart';
import '../core/network/connectivity_service.dart';
import '../core/router/app_router.dart';
import '../core/router/route_guard.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_snackbar.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = getIt<AppRouter>();
  final _connectivity = getIt<ConnectivityService>();

  // Splash/loading is only meaningful while the app is determining the
  // initial session on boot. Later AuthLoading emissions (login, register,
  // OTP, etc.) share the same state class but must not bounce the router
  // back to the splash screen mid-flow.
  bool _authDetermined = false;

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      if (!_authDetermined) {
        _router.updateAuthState(const RouteAuthState.loading());
      }
    } else if (state is AuthAuthenticated) {
      _authDetermined = true;
      // kyc_status is no longer used to gate navigation; authenticated
      // users always land on Home regardless of pending KYC.
      _router.updateAuthState(const RouteAuthState.authenticated());
    } else if (state is AuthUnauthenticated) {
      _authDetermined = true;
      _router.updateAuthState(const RouteAuthState.unauthenticated());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>()..add(const CheckAuthStatusRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: _onAuthStateChanged,
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return StreamBuilder<bool>(
              stream: _connectivity.isConnected,
              builder: (context, snapshot) {
                final isConnected = snapshot.data ?? true;
                return MaterialApp.router(
                  title: 'Bingo Pay',
                  theme: AppTheme.light,
                  debugShowCheckedModeBanner: false,
                  darkTheme: AppTheme.dark,
                  routerConfig: _router.router,
                  builder: (context, child) {
                    if (!isConnected) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted)
                          AppSnackbar.showOfflineBanner(context);
                      });
                    }
                    return child ?? const SizedBox.shrink();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
