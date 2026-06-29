import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          AppSnackbar.showSuccess(context, state.message);
          context.go(AppRoutes.login);
        } else if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        } else if (state is AuthError) {
          AppSnackbar.showError(context, state.failure.message);
        }
      },
      child: BlocBuilder<AccountCubit, AccountState>(
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

        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final isLoggingOut = authState is AuthLoading;
            return Stack(
              children: [
                Scaffold(
                  backgroundColor: ThemeColors.blue,
                  body: RefreshIndicator(
                    onRefresh: cubit.refresh,
                    color: ThemeColors.blue,
                    backgroundColor: ThemeColors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          AccountHeader(
                            account: loaded.account,
                            onEdit: cubit.onEditProfile,
                            onWalletTap: () => context.push(AppRoutes.wallet),
                          ),
                          SizedBox(height: 2.5.h),
                          AccountMenuList(
                            items: AccountMenuItem.items,
                            onTap: (item) => context.push(item.route),
                          ),
                          SizedBox(height: 3.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: AppButton(
                              label: 'LogOut',
                              isLoading: isLoggingOut,
                              onPressed: isLoggingOut
                                  ? null
                                  : () => context
                                      .read<AuthBloc>()
                                      .add(const LogoutRequested()),
                              prefixIcon: Icons.logout_rounded,
                              variant: AppButtonVariant.secondary,
                            ),
                          ),
                          SizedBox(height: 15.5.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // Full-screen loading overlay during logout
                if (isLoggingOut)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: ThemeColors.blue,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Logging out...',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: ThemeColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
      ),
    );
  }
}
