import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/router/route_guard.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/account_model/account_model.dart';
import '../cubit/account_cubit.dart';
import '../widgets/account_header.dart';
import '../widgets/account_menu_list.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AccountCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        // ── Loading / Initial ────────────────────────────────────────────
        if (state is AccountInitial || state is AccountLoading) {
          return const Scaffold(
            backgroundColor: ThemeColors.blue,
            body: Center(
              child: CircularProgressIndicator(color: ThemeColors.white),
            ),
          );
        }

        // ── Error ────────────────────────────────────────────────────────
        if (state is AccountError) {
          return Scaffold(
            backgroundColor: ThemeColors.blue,
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: ThemeColors.white,
                      size: 52,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      state.message,
                      style: const TextStyle(
                        color: ThemeColors.white,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 3.h),
                    OutlinedButton(
                      onPressed: () => context.read<AccountCubit>().refresh(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeColors.white,
                        side: const BorderSide(color: ThemeColors.white),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 1.5.h,
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ── Loaded ───────────────────────────────────────────────────────
        final loaded = state as AccountLoaded;
        final cubit = context.read<AccountCubit>();

        return Scaffold(
          backgroundColor: ThemeColors.blue,
          body: RefreshIndicator(
            onRefresh: cubit.refresh,
            color: ThemeColors.blue,
            backgroundColor: ThemeColors.white,
            child: SingleChildScrollView(
              // Enables pull-to-refresh even when content fits the screen.
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // ── Blue gradient header (avatar, name, stats) ─────────
                  AccountHeader(
                    account: loaded.account,
                    onEdit: cubit.onEditProfile,
                    onWalletTap: () => context.push(AppRoutes.wallet),
                  ),

                  SizedBox(height: 2.5.h),

                  // ── White menu card ───────────────────────────────────
                  AccountMenuList(
                    items: AccountMenuItem.items,
                    onTap: (item) => context.push(item.route),
                  ),

                  SizedBox(height: 3.h),

                  // ── Log out ───────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: AppButton(
                      label: 'LogOut',
                      onPressed: () async {
                        await getIt<PreferencesService>().clear();

                        getIt<AppRouter>().updateAuthState(
                          const RouteAuthState.unauthenticated(),
                        );

                        if (context.mounted) {
                          context.go(AppRoutes.login);
                        }
                      },

                      prefixIcon: Icons.logout_rounded,
                      variant: AppButtonVariant.secondary,
                    ),
                  ),

                  SizedBox(height: 15.5.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
