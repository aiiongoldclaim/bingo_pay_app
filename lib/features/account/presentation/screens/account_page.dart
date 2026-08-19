// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/app_theme_colors.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/widgets/app_button.dart';
// import '../../../../core/widgets/app_snackbar.dart';
// import '../../../auth/presentation/bloc/auth_bloc.dart';
// import '../../../auth/presentation/bloc/auth_event.dart';
// import '../../../auth/presentation/bloc/auth_state.dart';
// import '../cubit/account_cubit.dart';
// import '../widgets/account_header.dart';
// import '../widgets/account_menu_list.dart';
//
// class AccountScreen extends StatefulWidget {
//   const AccountScreen({super.key});
//
//   @override
//   State<AccountScreen> createState() => _AccountScreenState();
// }
//
// class _AccountScreenState extends State<AccountScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<AccountCubit>().loadProfile();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthLoggedOut) {
//           AppSnackbar.showSuccess(context, state.message);
//           context.go(AppRoutes.login);
//         } else if (state is AuthUnauthenticated) {
//           context.go(AppRoutes.login);
//         } else if (state is AuthError) {
//           AppSnackbar.showError(context, state.failure.message);
//         }
//       },
//       child: BlocBuilder<AccountCubit, AccountState>(
//         builder: (context, state) {
//           // ── Loading / Initial ────────────────────────────────────────────
//           if (state is AccountInitial || state is AccountLoading) {
//             return const Scaffold(
//               backgroundColor: ThemeColors.white,
//               body: Center(
//                 child: CircularProgressIndicator(color: ThemeColors.white),
//               ),
//             );
//           }
//
//           // ── Error ────────────────────────────────────────────────────────
//           if (state is AccountError) {
//             return Scaffold(
//               backgroundColor: ThemeColors.white,
//               body: Center(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 6.w),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(
//                         Icons.error_outline_rounded,
//                         color: ThemeColors.white,
//                         size: 52,
//                       ),
//                       SizedBox(height: 2.h),
//                       Text(
//                         state.message,
//                         style: const TextStyle(
//                           color: ThemeColors.white,
//                           fontSize: 15,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 3.h),
//                       OutlinedButton(
//                         onPressed: () => context.read<AccountCubit>().refresh(),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: ThemeColors.white,
//                           side: const BorderSide(color: ThemeColors.white),
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 8.w,
//                             vertical: 1.5.h,
//                           ),
//                         ),
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }
//
//           // ── Loaded ───────────────────────────────────────────────────────
//           final loaded = state as AccountLoaded;
//           final cubit = context.read<AccountCubit>();
//
//           return BlocBuilder<AuthBloc, AuthState>(
//             builder: (context, authState) {
//               final isLoggingOut = authState is AuthLoading;
//               return Stack(
//                 children: [
//                   Scaffold(
//                     backgroundColor: ThemeColors.white,
//                     body: RefreshIndicator(
//                       onRefresh: cubit.refresh,
//                       color: ThemeColors.white,
//                       backgroundColor: ThemeColors.white,
//                       child: SingleChildScrollView(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         child: Column(
//                           children: [
//                             AccountHeader(
//                               account: loaded.account,
//                               onEdit: cubit.onEditProfile,
//                               onWalletTap: () => context.push(AppRoutes.wallet),
//                             ),
//                             SizedBox(height: 2.5.h),
//                             AccountMenuList(
//                               items: AccountMenuItem.items,
//                               onTap: (item) => context.push(item.route),
//                             ),
//                             SizedBox(height: 3.h),
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 4.w),
//                               child: AppButton(
//                                 label: 'LogOut',
//
//                                 isLoading: false,
//                                 onPressed: isLoggingOut
//                                     ? null
//                                     : () => context.read<AuthBloc>().add(
//                                         const LogoutRequested(),
//                                       ),
//                                 prefixIcon: Icons.logout_rounded,
//                                 variant: AppButtonVariant.primary,
//                               ),
//                             ),
//                             SizedBox(height: 15.5.h),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // Full-screen loading overlay during logout
//                   if (isLoggingOut)
//                     Container(
//                       color: Colors.black.withValues(alpha: 0.5),
//                       child: Center(
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 8.w,
//                             vertical: 3.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: ThemeColors.white,
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const CircularProgressIndicator(
//                                 color: ThemeColors.purple,
//                               ),
//                               SizedBox(height: 2.h),
//                               Text(
//                                 'Logging out...',
//                                 style: TextStyle(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                   color: ThemeColors.purple,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _AppBarRow extends StatelessWidget {
//   final String title;
//   final VoidCallback onEdit;
//
//   const _AppBarRow({required this.title, required this.onEdit});
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
//       child: Row(
//         children: [
//           Text(
//             title,
//             style: AppTextStyles.titleLarge.copyWith(
//               color: c.textPrimary,
//               fontFamily: "CormorantGaramond",
//               fontSize: 22.sp,
//             ),
//           ),
//           const Spacer(),
//
//           IconButton(
//             color: c.textPrimary,
//             icon: const Icon(Icons.settings),
//             onPressed: () {},
//           ),
//           IconButton(
//             color: c.textPrimary,
//             icon: const Icon(Icons.notifications),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/svg_image.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/account_cubit.dart';
import '../widgets/account_benefits_strip.dart';
import '../widgets/account_header.dart';
import '../widgets/account_menu_list.dart';
import '../widgets/account_metrics.dart';

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
    final c = context.c;

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
            return Scaffold(
              backgroundColor: c.background,
              body: Center(child: CircularProgressIndicator(color: c.brand)),
            );
          }

          // ── Error ────────────────────────────────────────────────────────
          if (state is AccountError) {
            final m = AccountMetrics.of(context);
            return Scaffold(
              backgroundColor: c.background,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: c.brand,
                        size: m.walletIconSize * 1.6,
                      ),
                      SizedBox(height: m.gapMd),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: c.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: m.menuTitleSize,
                        ),
                      ),
                      SizedBox(height: m.gapLg),
                      OutlinedButton(
                        onPressed: () => context.read<AccountCubit>().refresh(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.brand,
                          side: BorderSide(color: c.brand),
                          padding: EdgeInsets.symmetric(
                            horizontal: m.walletHPad * 1.8,
                            vertical: m.menuItemVPad,
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
              final m = AccountMetrics.of(context);

              return Stack(
                children: [
                  Scaffold(
                    appBar: AccountAppBar(
                      onSettingsTap: () {},
                      onNotificationTap: () {},
                    ),
                    backgroundColor: c.background,
                    body: RefreshIndicator(
                      onRefresh: cubit.refresh,
                      color: c.brand,
                      backgroundColor: c.surface,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            AccountHeader(
                              account: loaded.account,
                              onEdit: cubit.onEditProfile,
                              onWalletTap: () => context.push(AppRoutes.wallet),
                            ),
                            SizedBox(height: m.gapMd),
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: m.maxContentWidth,
                                ),
                                child: Column(
                                  children: [
                                    AccountMenuList(
                                      items: AccountMenuItem.primaryItems,
                                      onTap: (item) {
                                        if (item.route.isNotEmpty) {
                                          context.push(item.route);
                                        }
                                      },
                                    ),
                                    SizedBox(height: m.gapMd),
                                    _SecondaryGroup(
                                      metrics: m,
                                      isLoggingOut: isLoggingOut,
                                    ),
                                    const AccountBenefitsStrip(),
                                    SizedBox(height: m.bottomPad * 2),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Full-screen loading overlay during logout
                  if (isLoggingOut)
                    Container(
                      color: c.textPrimary.withValues(alpha: 0.45),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: m.walletHPad * 1.8,
                            vertical: m.gapLg,
                          ),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(m.menuRadius),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: c.brand),
                              SizedBox(height: m.gapMd),
                              Text(
                                'Logging out...',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: c.brand,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: m.menuTitleSize,
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

/// Help & Support + Edit Profile + Logout — ek hi card group me (image jaisa)
class _SecondaryGroup extends StatelessWidget {
  final AccountMetrics metrics;
  final bool isLoggingOut;

  const _SecondaryGroup({required this.metrics, required this.isLoggingOut});

  Future<void> _confirmLogout(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Logout?',
      message: 'Are you sure you want to logOut from your account',
      confirmLabel: 'Logout',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );

    if (!confirmed) return;
    authBloc.add(const LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final items = AccountMenuItem.secondaryItems;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: m.pageHPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.menuRadius),
        border: Border.all(color: c.border, width: 1),
        boxShadow: c.isDark
            ? null
            : [
                BoxShadow(
                  color: c.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: [
          ...List.generate(items.length, (i) {
            final item = items[i];
            return Column(
              children: [
                _SecondaryTile(
                  iconAsset: item.iconAsset == 'help'
                      ? AppSvgImages.support
                      : AppSvgImages.profile,
                  title: item.title,
                  subtitle: item.subtitle,
                  metrics: m,
                  isFirst: i == 0,
                  isLast: false,
                  onTap: () {
                    if (item.route.isNotEmpty) context.push(item.route);
                  },
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: m.dividerIndent,
                  endIndent: m.menuItemHPad,
                  color: c.border,
                ),
              ],
            );
          }),
          _SecondaryTile(
            iconAsset: AppSvgImages.logout,
            title: 'Logout',
            subtitle: 'Sign out from your account',
            metrics: m,
            isFirst: false,
            isLast: true,
            onTap: isLoggingOut ? null : () => _confirmLogout(context),
            // onTap: isLoggingOut
            //     ? null
            //     : () => context.read<AuthBloc>().add(const LogoutRequested()),
          ),
          // _SecondaryTile(
          //   iconAsset: AppSvgImages.logout,
          //   title: 'Scanner Pay and Review',
          //   subtitle: '',
          //   metrics: m,
          //   isFirst: false,
          //   isLast: true,
          //   onTap: () {
          //     context.go(AppRoutes.reviewPayment);
          //   },
          // ),
        ],
      ),
    );
  }
}

class _SecondaryTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final AccountMetrics metrics;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const _SecondaryTile({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.metrics,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirst ? m.menuRadius : 0),
          bottom: Radius.circular(isLast ? m.menuRadius : 0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: m.menuItemHPad,
            vertical: m.menuItemVPad,
          ),
          child: Row(
            children: [
              _Icon(asset: iconAsset, size: m.menuIconSize, color: c.brand),
              SizedBox(width: m.menuIconGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: m.menuTitleSize,
                      ),
                    ),
                    SizedBox(height: m.gapXs),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.menuSubtitleSize,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: m.gapSm),
              Icon(
                Icons.chevron_right_rounded,
                size: m.chevronSize + 6,
                color: c.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;

  const _Icon({required this.asset, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
