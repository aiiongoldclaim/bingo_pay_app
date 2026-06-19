import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      _router.updateAuthState(
        RouteAuthState.authenticated(isKycPending: state.user.isKycPending),
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
        child: StreamBuilder<bool>(
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
                    if (context.mounted) AppSnackbar.showOfflineBanner(context);
                  });
                }
                return child ?? const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}
