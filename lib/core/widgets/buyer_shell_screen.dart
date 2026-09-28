import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import 'custom_bottom_nav.dart';
import '../di/injection.dart';
import '../../features/home/presentation/cubit/dashboard_cubit.dart';
import '../../features/home/presentation/cubit/dashboard_state.dart';
import '../../features/home/presentation/models/vault_theme_colors.dart';

class BuyerShellScreen extends StatefulWidget {
  final Widget child;
  final String location;

  const BuyerShellScreen({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  State<BuyerShellScreen> createState() => _BuyerShellScreenState();
}

class _BuyerShellScreenState extends State<BuyerShellScreen> {
  late final HomeCubit _homeCubit = getIt<HomeCubit>()..loadHome();

  @override
  void didUpdateWidget(covariant BuyerShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final enteredHome =
        widget.location.startsWith(AppRoutes.home) &&
        !oldWidget.location.startsWith(AppRoutes.home);
    if (enteredHome) {
      _homeCubit.loadHome();
    }
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  int get _selectedIndex {
    if (widget.location.startsWith(AppRoutes.home)) return 0;
    if (widget.location.startsWith(AppRoutes.categories)) return 1;
    if (widget.location.startsWith(AppRoutes.profile)) return 2;
    if (widget.location.startsWith(AppRoutes.splitViewNavigation)) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.push(AppRoutes.categories);
        break;
      case 2:
        context.push(AppRoutes.profile);
        break;
      case 3:
        context.push(AppRoutes.splitViewNavigation);
        break;
    }
  }

  static const _tabRootPaths = [
    AppRoutes.home,
    AppRoutes.categories,
    AppRoutes.profile,
    AppRoutes.splitViewNavigation,
  ];

  @override
  Widget build(BuildContext context) {
    final hideNav = !_tabRootPaths.any(
      (path) => widget.location.startsWith(path),
    );

    return Scaffold(
      extendBody: true,
      body: BlocProvider<HomeCubit>.value(
        value: _homeCubit,
        child: widget.child,
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      // ── Glass bottom nav ─────────────────────────────────────────────────
      bottomNavigationBar: hideNav
          ? null
          : BlocBuilder<HomeCubit, HomeState>(
              bloc: _homeCubit,
              builder: (context, homeState) {
                final activeColorOverride = _selectedIndex == 0
                    ? VaultThemeColors.forSection(
                        homeState.selectedVaultSection,
                      ).primary
                    : null;
                return CustomBottomNav(
                  currentIndex: _selectedIndex,
                  activeColorOverride: activeColorOverride,
                  onTap: (index) => _onTap(context, index),
                );
              },
            ),
    );
  }
}
