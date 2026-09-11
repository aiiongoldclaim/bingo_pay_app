// ─────────────────────────────────────────────────────────────────────────
// ORIGINAL — Profile screen using the shared CustomAppBar (plain title,
// settings + notifications icons, no subtitle), kept for reference. The
// redesigned screen uses a custom fixed header (big "Profile" title,
// subtitle, circular settings/notifications buttons on a soft gradient
// wash) matching the new mockup — see the active ProfileScreen
// implementation below.
// ─────────────────────────────────────────────────────────────────────────
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/theme/app_theme_colors.dart';
// import '../../../../core/widgets/app_shimmer.dart';
// import '../../../../core/widgets/app_snackbar.dart';
// import '../../../../core/widgets/custom_app_bar.dart';
// import '../../../auth/presentation/bloc/auth_bloc.dart';
// import '../../../auth/presentation/bloc/auth_state.dart';
// import '../cubit/profile_cubit.dart';
// import '../widgets/profile_error_view.dart';
// import '../widgets/profile_header.dart';
// import '../widgets/profile_membership_card.dart';
// import '../widgets/profile_menu_list.dart';
// import '../widgets/profile_metrics.dart';
// import '../widgets/profile_secondary_section.dart';
// import '../widgets/profile_shimmer.dart';
// import '../../domain/enities/profile_entity.dart';
// import '../../../membershipNew/presentation/cubit/membership_cubit.dart';
// import '../../../membershipNew/presentation/cubit/membership_state.dart';
//
// import 'package:bingo_pay/core/di/injection.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<ProfileCubit>(
//           create: (_) => getIt<ProfileCubit>()..loadProfile(),
//         ),
//         BlocProvider<MembershipCubit>(
//           create: (_) => getIt<MembershipCubit>()..load(),
//         ),
//       ],
//       child: const _ProfileScreenBody(),
//     );
//   }
// }
//
// class _ProfileScreenBody extends StatelessWidget {
//   const _ProfileScreenBody();
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthLoggedOut) {
//           AppSnackbar.showSuccess(context, state.message);
//
//           context.go(AppRoutes.login);
//         } else if (state is AuthUnauthenticated) {
//           context.go(AppRoutes.login);
//         } else if (state is AuthError) {
//           AppSnackbar.showError(context, state.failure.message);
//         }
//       },
//       child: BlocBuilder<ProfileCubit, ProfileState>(
//         builder: (context, accountState) {
//           final colors = context.c;
//
//           if (accountState is ProfileInitial ||
//               accountState is ProfileLoading) {
//             return Scaffold(
//               backgroundColor: colors.background,
//               body: SafeArea(
//                 child: AppShimmer(
//                   backgroundColor: colors.background,
//                   child: const ProfileShimmerContent(),
//                 ),
//               ),
//             );
//           }
//
//           if (accountState is ProfileRefreshing) {
//             return Stack(
//               children: [
//                 _ProfileLoadedContent(profile: accountState.profile),
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     child: AppShimmer(
//                       backgroundColor: colors.background,
//                       child: const ProfileShimmerContent(),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }
//
//           if (accountState is ProfileError) {
//             return ProfileErrorView(
//               message: accountState.message,
//               onRetry: () {
//                 context.read<ProfileCubit>().loadProfile();
//                 context.read<MembershipCubit>().load();
//               },
//             );
//           }
//
//           if (accountState is ProfileLoaded) {
//             return _ProfileLoadedContent(profile: accountState.profile);
//           }
//
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }
//
// class _ProfileLoadedContent extends StatelessWidget {
//   const _ProfileLoadedContent({required this.profile});
//
//   final ProfileEntity profile;
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.c;
//     final m = ProfileMetrics.of(context);
//
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, authState) {
//         final isLoggingOut = authState is AuthLoading;
//
//         return Stack(
//           children: [
//             Scaffold(
//               appBar: CustomAppBar(
//                 title: 'Profile',
//                 showBackButton: false,
//                 actionIcon1: Icons.settings,
//                 onAction1: () => context.push(AppRoutes.buyerSettings),
//                 actionIcon2: Icons.notifications_none_outlined,
//                 onAction2: () => context.push(AppRoutes.buyerNotifications),
//                 actionIconSize: 26,
//                 actionIconGap: 3,
//               ),
//               backgroundColor: colors.background,
//               body: RefreshIndicator(
//                 onRefresh: () async {
//                   await Future.wait([
//                     context.read<ProfileCubit>().refresh(),
//                     context.read<MembershipCubit>().refresh(),
//                   ]);
//                 },
//                 color: colors.brand,
//                 backgroundColor: colors.surface,
//                 child: SingleChildScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   child: Column(
//                     children: [
//                       ProfileHeader(
//                         profile: profile,
//                         onEdit: context.read<ProfileCubit>().onEditProfile,
//                         onWalletTap: () {
//                           context.push(AppRoutes.wallet);
//                         },
//                       ),
//
//                       SizedBox(height: m.gapMd),
//
//                       BlocBuilder<MembershipCubit, MembershipState>(
//                         builder: (context, membershipState) {
//                           if (membershipState is! MembershipLoaded) {
//                             return const SizedBox.shrink();
//                           }
//
//                           final hasMembership =
//                               membershipState.membership.subscription != null;
//
//                           if (!hasMembership) {
//                             return const SizedBox.shrink();
//                           }
//
//                           return ProfileMembershipCard(
//                             maxWidth: m.maxContentWidth,
//                             onTap: () {
//                               context.push(AppRoutes.membership);
//                             },
//                           );
//                         },
//                       ),
//
//                       SizedBox(height: m.gapMd),
//
//                       Center(
//                         child: ConstrainedBox(
//                           constraints: BoxConstraints(
//                             maxWidth: m.maxContentWidth,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               ProfileSectionHeading(
//                                 metrics: m,
//                                 label: 'My Orders & Shopping',
//                               ),
//
//                               SizedBox(height: m.sectionHeadingGap),
//
//                               ProfileMenuList(
//                                 items: ProfileMenuItem.primaryItems,
//                                 onTap: (item) {
//                                   if (item.route.isNotEmpty) {
//                                     context.push(item.route);
//                                   }
//                                 },
//                               ),
//
//                               SizedBox(height: m.gapLg),
//
//                               ProfileSectionHeading(
//                                 metrics: m,
//                                 label: 'Account & Support',
//                               ),
//
//                               SizedBox(height: m.sectionHeadingGap),
//
//                               ProfileSecondaryGroup(
//                                 metrics: m,
//                                 isLoggingOut: isLoggingOut,
//                               ),
//
//                               SizedBox(height: m.bottomPad * 3),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             if (isLoggingOut) ProfileLogoutOverlay(metrics: m),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_error_view.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_membership_card.dart';
import '../widgets/profile_menu_list.dart';
import '../widgets/profile_metrics.dart';
import '../widgets/profile_secondary_section.dart';
import '../widgets/profile_shimmer.dart';
import '../../domain/enities/profile_entity.dart';
import '../../../membershipNew/presentation/cubit/membership_cubit.dart';
import '../../../membershipNew/presentation/cubit/membership_state.dart';

import 'package:bingo_pay/core/di/injection.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create: (_) => getIt<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider<MembershipCubit>(
          create: (_) => getIt<MembershipCubit>()..load(),
        ),
      ],
      child: const _ProfileScreenBody(),
    );
  }
}

class _ProfileScreenBody extends StatelessWidget {
  const _ProfileScreenBody();

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

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
      child: Scaffold(
        backgroundColor: colors.background,
        body: Column(
          children: [
            const _ProfileTopBar(),
            Expanded(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, accountState) {
                  if (accountState is ProfileInitial ||
                      accountState is ProfileLoading) {
                    return AppShimmer(
                      backgroundColor: colors.background,
                      child: const ProfileShimmerContent(),
                    );
                  }
        
                  if (accountState is ProfileRefreshing) {
                    return Stack(
                      children: [
                        _ProfileLoadedContent(profile: accountState.profile),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AppShimmer(
                              backgroundColor: colors.background,
                              child: const ProfileShimmerContent(),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
        
                  if (accountState is ProfileError) {
                    return ProfileErrorView(
                      message: accountState.message,
                      onRetry: () {
                        context.read<ProfileCubit>().loadProfile();
                        context.read<MembershipCubit>().load();
                      },
                    );
                  }
        
                  if (accountState is ProfileLoaded) {
                    return _ProfileLoadedContent(
                      profile: accountState.profile,
                    );
                  }
        
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar();

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = ProfileMetrics.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.brandSoft, colors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            m.appBarHPad,
            m.appBarVPad,
            m.appBarHPad,
            m.appBarVPad,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Profile',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.titleSize - 6,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.6),
                    Text(
                      'Manage your account and preferences',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.emailSize, 
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: m.gapSm),
              _CircleIconButton(
                icon: Icons.settings,
                metrics: m,
                onTap: () => context.push(AppRoutes.buyerSettings),
              ),
              SizedBox(width: m.gapSm * 0.7),
              _CircleIconButton(
                icon: Icons.notifications_none_outlined,
                metrics: m,
                onTap: () => context.push(AppRoutes.buyerNotifications),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final ProfileMetrics metrics;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.metrics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final iconSize = m.appBarIconSize * 0.85;
    final size = m.appBarIconSize * 1.8;

    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: colors.textPrimary),
        ),
      ),
    );
  }
}

class _ProfileLoadedContent extends StatelessWidget {
  const _ProfileLoadedContent({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = ProfileMetrics.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isLoggingOut = authState is AuthLoading;

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  context.read<ProfileCubit>().refresh(),
                  context.read<MembershipCubit>().refresh(),
                ]);
              },
              color: colors.brand,
              backgroundColor: colors.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: m.gapSm),

                    ProfileHeader(
                      profile: profile,
                      onEdit: context.read<ProfileCubit>().onEditProfile,
                      onWalletTap: () {
                        context.push(AppRoutes.wallet);
                      },
                    ),

                    SizedBox(height: m.gapMd),

                    BlocBuilder<MembershipCubit, MembershipState>(
                      builder: (context, membershipState) {
                        if (membershipState is! MembershipLoaded) {
                          return const SizedBox.shrink();
                        }

                        final hasMembership =
                            membershipState.membership.subscription != null;

                        if (!hasMembership) {
                          return const SizedBox.shrink();
                        }

                        return ProfileMembershipCard(
                          maxWidth: m.maxContentWidth,
                          onTap: () {
                            context.push(AppRoutes.membership);
                          },
                        );
                      },
                    ),

                    SizedBox(height: m.gapMd),

                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: m.maxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileSectionHeading(
                              metrics: m,
                              label: 'My Orders & Shopping',
                            ),

                            SizedBox(height: m.sectionHeadingGap),

                            ProfileMenuList(
                              items: ProfileMenuItem.primaryItems,
                              onTap: (item) {
                                if (item.route.isNotEmpty) {
                                  context.push(item.route);
                                }
                              },
                            ),

                            SizedBox(height: m.gapLg),

                            ProfileSectionHeading(
                              metrics: m,
                              label: 'Account & Support',
                            ),

                            SizedBox(height: m.sectionHeadingGap),

                            ProfileSecondaryGroup(
                              metrics: m,
                              isLoggingOut: isLoggingOut,
                            ),

                            SizedBox(height: m.bottomPad * 3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isLoggingOut) ProfileLogoutOverlay(metrics: m),
          ],
        );
      },
    );
  }
}
