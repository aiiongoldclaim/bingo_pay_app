import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import '../core/di/injection.dart';
import '../core/network/connectivity_service.dart';
import '../core/router/app_router.dart';
import '../core/router/route_guard.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/offline_screen.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

/// The observer is registered in initState — before the Router mounts — so
/// it sees system back presses first: while offline, back exits the app
/// instead of popping the (hidden) route below the offline screen.
class _AppState extends State<App> with WidgetsBindingObserver {
  final _router = getIt<AppRouter>();
  final _connectivity = getIt<ConnectivityService>();
  StreamSubscription<bool>? _connectivitySub;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivitySub = _connectivity.isConnected.listen((connected) {
      if (connected != _isConnected) {
        setState(() => _isConnected = connected);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (_isConnected) return false;
    await SystemNavigator.pop();
    return true;
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      _router.updateAuthState(
        RouteAuthState.authenticated(kybStatus: state.user.effectiveKybStatus),
      );
    } else if (state is AuthUnauthenticated) {
      _router.updateAuthState(const RouteAuthState.unauthenticated());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) =>
          getIt<AuthBloc>()..add(const CheckAuthStatusRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: _onAuthStateChanged,
        child: ToastificationWrapper(
          child: MaterialApp.router(
            title: 'Bingo Pay',
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            darkTheme: AppTheme.dark,
            routerConfig: _router.router,
            builder: (context, child) {
              // While offline, a full-screen glass page covers the app. The
              // route stack underneath is never touched, so the user lands
              // back exactly where they were once connectivity returns.
              return Stack(
                children: [
                  child ?? const SizedBox.shrink(),
                  if (!_isConnected)
                    const Positioned.fill(child: OfflineScreen()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
