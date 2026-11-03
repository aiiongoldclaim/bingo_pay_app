import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/tvs_wallet_cubit.dart';
import '../cubit/tvs_wallet_state.dart';
import '../widgets/tvs_activity.dart';
import '../widgets/tvs_format.dart';
import '../widgets/tvs_invite_tab.dart';
import '../widgets/tvs_offers_tab.dart';
import '../widgets/tvs_receive_sheet.dart';
import '../widgets/tvs_ui.dart';

// My TVS Wallet: balance (own coins + bonus), activation, adding money,
// sending and receiving coins, the MPIN, activity, bonus expiry, offers and
// invites — the app's twin of the web wallet page.
class TvsWalletScreen extends StatelessWidget {
  const TvsWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TvsWalletCubit>()..load(),
      child: const _WalletBody(),
    );
  }
}

enum _Tab { activity, bonus, offers, invite }

const _tabLabels = {
  _Tab.activity: 'Activity',
  _Tab.bonus: 'Bonus',
  _Tab.offers: 'Offers',
  _Tab.invite: 'Invite',
};

class _WalletBody extends StatefulWidget {
  const _WalletBody();

  @override
  State<_WalletBody> createState() => _WalletBodyState();
}

class _WalletBodyState extends State<_WalletBody> {
  _Tab _tab = _Tab.activity;

  // Opens a wallet screen; reloads when it says something changed (or always,
  // for KYC, which can activate the wallet).
  Future<void> _open(String route, {Object? extra, bool reload = false}) async {
    final cubit = context.read<TvsWalletCubit>();
    final changed = await context.push<bool>(route, extra: extra);
    if (changed == true || reload) cubit.load();
  }

  void _receive() {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      builder: (_) =>
          TvsReceiveSheet(userUuid: auth.user.id, email: auth.user.email),
    );
  }

  // Older activity loads as the list nears its end.
  bool _onScroll(ScrollNotification n) {
    if (_tab == _Tab.activity && n.metrics.extentAfter < 400) {
      context.read<TvsWalletCubit>().loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(
        title: 'TVS Wallet',
        actionIcon1: Icons.verified_user_outlined,
        onAction1: () => _open(AppRoutes.walletKyc, reload: true),
      ),
      body: BlocConsumer<TvsWalletCubit, TvsWalletState>(
        listenWhen: (a, b) =>
            b.summary != null && b.error != null && a.error != b.error,
        listener: (context, s) => AppSnackbar.showError(context, s.error!),
        builder: (context, s) {
          final cubit = context.read<TvsWalletCubit>();
          if (s.summary == null) {
            return s.error == null
                ? const _WalletShimmer()
                : _LoadError(message: s.error!, onRetry: cubit.load);
          }
          final home = s.home;
          final others = s.wallets.skip(1).toList();
          final pending = s.summary?['kycStatus'] == 'PENDING';

          return RefreshIndicator(
            onRefresh: cubit.load,
            color: colors.brand,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverList.list(
                      children: [
                        _BalanceCard(wallet: home, active: s.active),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _Action(
                              icon: Icons.add_rounded,
                              label: 'Add money',
                              onTap: s.active
                                  ? () => _open(AppRoutes.tvsTopup, extra: home)
                                  : null,
                            ),
                            _Action(
                              icon: Icons.north_east_rounded,
                              label: 'Send',
                              onTap: s.active
                                  ? () => _open(AppRoutes.tvsSend)
                                  : null,
                            ),
                            _Action(
                              icon: Icons.qr_code_2_rounded,
                              label: 'Receive',
                              onTap: _receive,
                            ),
                            _Action(
                              icon: Icons.pin_outlined,
                              label: 'MPIN',
                              onTap: () => context.push(AppRoutes.walletMpin),
                            ),
                          ],
                        ),
                        if (s.summary?['activationRequired'] == true) ...[
                          const SizedBox(height: 16),
                          _Banner(
                            color: colors.statusWarning,
                            icon: pending
                                ? Icons.hourglass_top_rounded
                                : Icons.shield_outlined,
                            title: pending
                                ? 'Verification in review'
                                : 'Activate your wallet',
                            text: pending
                                ? 'We’re checking your documents. You can already receive bonus coins.'
                                : 'Verify your identity to spend, add money and send coins.',
                            action: pending
                                ? null
                                : (
                                    'Verify',
                                    () => _open(
                                      AppRoutes.walletKyc,
                                      reload: true,
                                    ),
                                  ),
                          ),
                        ],
                        if (home?['status'] == 'FROZEN') ...[
                          const SizedBox(height: 16),
                          _Banner(
                            color: colors.error,
                            icon: Icons.lock_outline_rounded,
                            title: 'Wallet on hold',
                            text: home?['statusReason'] == null
                                ? 'Contact support to find out why.'
                                : '${home?['statusReason']}. Contact support.',
                          ),
                        ],
                        if (others.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final w in others)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: Text(
                                    '${tvsCoins(w['spendable'], w['currency'])} · ${w['currency']} wallet',
                                    style: tvsText(
                                      colors.textPrimary,
                                      size: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  // The tabs stay at the top while their content scrolls.
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PinnedTabs(
                      background: colors.background,
                      child: _Segmented(
                        value: _tab,
                        onChanged: (t) => setState(() => _tab = t),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    sliver: SliverToBoxAdapter(
                      child: switch (_tab) {
                        _Tab.activity => TvsActivityList(
                          state: s,
                          onLoadMore: cubit.loadMore,
                        ),
                        _Tab.bonus => TvsBonusList(
                          walletUuid: home?['uuid'] as String?,
                          currency: home?['currency'] as String?,
                        ),
                        _Tab.offers => const TvsOffersTab(),
                        _Tab.invite => const TvsInviteTab(),
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final Map<String, dynamic>? wallet;
  final bool active;

  const _BalanceCard({required this.wallet, required this.active});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final w = wallet;
    final cur = w?['currency'];
    final on = colors.onBrand;
    final muted = on.withValues(alpha: 0.72);
    final expiring = w?['bonusExpiringSoon'] as Map?;
    final expiringAmount = num.tryParse('${expiring?['amount']}') ?? 0;

    // "₹1,300.00": the paise smaller than the rupees.
    final amount = tvsCoins(active ? (w?['spendable']) : '0', cur);
    final dot = amount.lastIndexOf('.');
    final whole = dot < 0 ? amount : amount.substring(0, dot);
    final fraction = dot < 0 ? '' : amount.substring(dot);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [colors.brand, Color.lerp(colors.brand, Colors.black, 0.4)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Spendable balance', style: tvsText(muted, size: 13)),
              const Spacer(),
              if (w != null && !active)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: on.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tvsHuman(w['status']),
                    style: tvsText(on, size: 11, weight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: whole,
                  style: tvsText(on, size: 38, weight: FontWeight.w700),
                ),
                TextSpan(
                  text: fraction,
                  style: tvsText(muted, size: 22, weight: FontWeight.w600),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text('1 TVS Coin = 1 ${cur ?? ''}', style: tvsText(muted, size: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: on.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _Split('Own coins', tvsCoins(w?['available'], cur)),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: on.withValues(alpha: 0.18),
                  ),
                  _Split('Bonus', tvsCoins(w?['bonus'], cur)),
                ],
              ),
            ),
          ),
          if (expiringAmount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: colors.auctionAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${tvsCoins(expiring?['amount'], cur)} bonus expires '
                    '${tvsDate(expiring?['firstExpiresAt'])} · used first',
                    style: tvsText(colors.auctionAccent, size: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// One half of the own coins / bonus split on the balance card.
class _Split extends StatelessWidget {
  final String label;
  final String value;

  const _Split(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final on = context.colors.onBrand;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: tvsText(on.withValues(alpha: 0.72), size: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tvsText(on, size: 15, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap; // null: not available until the wallet is active

  const _Action({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Semantics(
          button: true,
          enabled: onTap != null,
          label: label,
          excludeSemantics: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: colors.brandSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: colors.brand, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tvsText(
                      colors.textPrimary,
                      size: 12,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// A pill-style switch between the wallet's lists.
class _Segmented extends StatelessWidget {
  final _Tab value;
  final ValueChanged<_Tab> onChanged;

  const _Segmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final t in _Tab.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: t == value,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: t == value
                        ? BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          )
                        : null,
                    child: Text(
                      _tabLabels[t]!,
                      style: tvsText(
                        t == value ? colors.textPrimary : colors.textSecondary,
                        size: 13,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PinnedTabs extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color background;

  const _PinnedTabs({required this.child, required this.background});

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_PinnedTabs old) => true;
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String text;
  final (String, VoidCallback)? action;

  const _Banner({
    required this.color,
    required this.icon,
    required this.title,
    required this.text,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tvsText(colors.textPrimary, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(text, style: tvsText(colors.textSecondary, size: 12)),
              ],
            ),
          ),
          if (action != null)
            TextButton(onPressed: action!.$2, child: Text(action!.$1)),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: tvsText(context.colors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

// The balance card, actions, tabs and a few activity rows, as shimmer.
class _WalletShimmer extends StatelessWidget {
  const _WalletShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const ShimmerLoading(
          child: ShimmerBox(
            height: 200,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        const SizedBox(height: 16),
        ShimmerLoading(
          child: Row(
            children: [
              for (var i = 0; i < 4; i++)
                const Expanded(
                  child: Column(
                    children: [
                      ShimmerBox(
                        width: 54,
                        height: 54,
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                      SizedBox(height: 6),
                      ShimmerBox(width: 48, height: 10),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const ShimmerLoading(
          child: ShimmerBox(
            height: 44,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        const SizedBox(height: 14),
        const TvsListShimmer(rows: 4),
      ],
    );
  }
}
