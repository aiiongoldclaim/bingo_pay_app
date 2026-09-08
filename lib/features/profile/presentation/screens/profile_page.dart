import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_membership_card.dart';
import '../widgets/profile_menu_list.dart';
import '../widgets/profile_metrics.dart';
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
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, accountState) {
          final colors = context.c;

          if (accountState is ProfileInitial ||
              accountState is ProfileLoading) {
            return Scaffold(
              backgroundColor: colors.background,
              body: SafeArea(
                child: AppShimmer(
                  backgroundColor: colors.background,
                  child: const ProfileShimmerContent(),
                ),
              ),
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
            return _ProfileErrorView(message: accountState.message);
          }

          if (accountState is ProfileLoaded) {
            return _ProfileLoadedContent(profile: accountState.profile);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileLoadedContent extends StatelessWidget {
  const _ProfileLoadedContent({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = ProfileMetrics.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isLoggingOut = authState is AuthLoading;

        return Stack(
          children: [
            Scaffold(
              appBar: ProfileAppBar(
                onSettingsTap: () {
                  context.push(AppRoutes.buyerSettings);
                },
                onNotificationTap: () {
                  context.push(AppRoutes.buyerNotifications);
                },
              ),
              backgroundColor: c.background,
              body: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    context.read<ProfileCubit>().refresh(),
                    context.read<MembershipCubit>().refresh(),
                  ]);
                },
                color: c.brand,
                backgroundColor: c.surface,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
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
                              _SectionHeading(
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

                              _SectionHeading(
                                metrics: m,
                                label: 'Account & Support',
                              ),

                              SizedBox(height: m.sectionHeadingGap),

                              _SecondaryGroup(
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
            ),

            if (isLoggingOut) _LogoutOverlay(metrics: m),
          ],
        );
      },
    );
  }
}

class ProfileShimmerContent extends StatelessWidget {
  const ProfileShimmerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 30),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ShimmerBox(
                  width: 72,
                  height: 72,
                  borderRadius: BorderRadius.all(Radius.circular(36)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 150, height: 20),
                      SizedBox(height: 10),
                      ShimmerBox(width: 200, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(
              width: double.infinity,
              height: 155,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(
              width: double.infinity,
              height: 90,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),

          const SizedBox(height: 28),

          _ShimmerSection(titleWidth: 180),

          const SizedBox(height: 20),

          _ShimmerSection(titleWidth: 160),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ShimmerSection extends StatelessWidget {
  const _ShimmerSection({required this.titleWidth});

  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ShimmerBox(width: titleWidth, height: 20),
          ),

          const SizedBox(height: 14),

          ...List.generate(3, (index) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ShimmerBox(
                width: double.infinity,
                height: 72,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = ProfileMetrics.of(context);

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
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.menuTitleSize,
                ),
              ),

              SizedBox(height: m.gapLg),

              OutlinedButton(
                onPressed: () {
                  context.read<ProfileCubit>().loadProfile();

                  context.read<MembershipCubit>().load();
                },
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
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.metrics, required this.label});

  final ProfileMetrics metrics;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: AppTextStyles.titleMedium.copyWith(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: m.sectionHeadingSize,
          ),
        ),
      ),
    );
  }
}

class _SecondaryGroup extends StatelessWidget {
  const _SecondaryGroup({required this.metrics, required this.isLoggingOut});

  final ProfileMetrics metrics;
  final bool isLoggingOut;

  Future<void> _confirmLogout(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Logout?',
      message: 'Are you sure you want to logOut from your profile',
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
    final items = ProfileMenuItem.secondaryItems;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: m.pageHPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.menuRadius),
        border: Border.all(color: c.border),
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
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  metrics: m,
                  isFirst: i == 0,
                  isLast: false,
                  onTap: () {
                    if (item.route.isNotEmpty) {
                      context.push(item.route);
                    }
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
            icon: ProfileMenuItem.iconFor('logout'),
            title: 'Logout',
            subtitle: 'Sign out from your profile',
            metrics: m,
            isFirst: false,
            isLast: true,
            onTap: isLoggingOut ? null : () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}

class _SecondaryTile extends StatelessWidget {
  const _SecondaryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.metrics,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ProfileMetrics metrics;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

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
              Container(
                width: m.menuIconBox,
                height: m.menuIconBox,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: m.menuIconSize, color: c.brand),
              ),

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

class _LogoutOverlay extends StatelessWidget {
  const _LogoutOverlay({required this.metrics});

  final ProfileMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Positioned.fill(
      child: Container(
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
    );
  }
}
