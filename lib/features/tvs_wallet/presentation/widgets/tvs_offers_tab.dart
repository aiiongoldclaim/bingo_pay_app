import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';
import 'tvs_format.dart';
import 'tvs_ui.dart';

const _where = {
  'Online checkout': 'Online orders',
  'Shop QR': 'Shop QR',
  'Any TVS payment': 'Online and shop QR',
  'Adding money': 'Adding money',
};

enum _List { coupons, discounts, rewards, progress, history }

// Offers & rewards, one list at a time: coupons I hold, discounts I get,
// cashback and rewards I can earn, rewards in progress, and history. Area
// offers follow my verified home address (or my saved address before KYC).
class TvsOffersTab extends StatefulWidget {
  const TvsOffersTab({super.key});

  @override
  State<TvsOffersTab> createState() => _TvsOffersTabState();
}

class _TvsOffersTabState extends State<TvsOffersTab> {
  final _api = getIt<TvsQrDataSource>();
  late final Future<(Map<String, dynamic>, List)> _data = _load();
  _List? _list;

  // Offers, plus reward history (an empty history if that one fails).
  Future<(Map<String, dynamic>, List)> _load() async {
    final history = _api.rewardsHistory().then(
      (h) => (h['items'] as List?) ?? const [],
      onError: (_) => const [],
    );
    return (await _api.offers(), await history);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) return const TvsEmpty('Could not load offers.');
        final data = snap.data;
        if (data == null) return const TvsListShimmer();
        return _body(context, data.$1, data.$2);
      },
    );
  }

  Widget _body(BuildContext context, Map<String, dynamic> data, List history) {
    final colors = context.colors;
    final cur = '${data['currency'] ?? ''}';
    String money(Object? v) => tvsCoins(v, cur).replaceAll('.00', '');
    List<Map> list(String key) =>
        ((data[key] as List?) ?? const []).cast<Map>();

    final coupons = list('coupons');
    final forYou = list('forYou');
    final discounts = forYou.where((o) => o['kind'] == 'DISCOUNT').toList();
    final rewards = forYou.where((o) => o['kind'] == 'REWARD').toList();
    final progress = [
      ...list('inProgress'),
      for (final r in list('onTheWay')) {...r, 'onTheWay': true},
    ];
    final counts = {
      _List.coupons: coupons.length,
      _List.discounts: discounts.length,
      _List.rewards: rewards.length,
      _List.progress: progress.length,
      _List.history: history.length,
    };
    const labels = {
      _List.coupons: 'Coupons',
      _List.discounts: 'Discounts',
      _List.rewards: 'Cashback & rewards',
      _List.progress: 'In progress',
      _List.history: 'History',
    };
    // Open on the first list with something in it.
    final current =
        _list ??
        _List.values.firstWhere(
          (l) => counts[l]! > 0,
          orElse: () => _List.coupons,
        );
    final loc = (data['location'] as Map?) ?? const {};

    String join(List<Object?> parts) => parts
        .where((p) => p != null && p != false && '$p'.isNotEmpty)
        .join(' · ');

    final rows = switch (current) {
      _List.coupons => [
        for (final c in coupons)
          _OfferRow(
            badge: _badge(c['deal'] as Map?, money),
            title: '${c['name']}',
            sub: c['applicable'] == false
                ? null
                : join([
                    _where[c['where']] ?? c['where'],
                    c['minimum'] == null
                        ? null
                        : 'min. order ${money(c['minimum'])}',
                  ]),
            warning: c['applicable'] == false ? '${c['reason']}' : null,
            right: c['expiresAt'] == null
                ? null
                : 'Valid till ${tvsDate(c['expiresAt'])}',
            terms: c['terms'] as String?,
          ),
      ],
      _List.discounts => [
        for (final o in discounts)
          _OfferRow(
            badge: _badge(o['deal'] as Map?, money),
            title: '${o['name']}',
            sub: join([
              _where[o['on']] ?? o['on'],
              o['minimum'] == null ? null : 'min. order ${money(o['minimum'])}',
              'applies automatically',
            ]),
            right: o['endsAt'] == null ? null : 'Till ${tvsDate(o['endsAt'])}',
            terms: o['terms'] as String?,
          ),
      ],
      _List.rewards => [
        for (final o in rewards)
          _OfferRow(
            badge: _badge(o['deal'] as Map?, money, reward: true),
            gold: true,
            title: '${o['name']}',
            sub: join([
              _where[o['on']] ?? o['on'],
              o['minimum'] == null ? null : 'min. ${money(o['minimum'])}',
              o['firstTopupOnly'] == true ? 'first top-up only' : null,
              _milestone(o['milestone'] as Map?),
            ]),
            right: o['endsAt'] == null ? null : 'Till ${tvsDate(o['endsAt'])}',
            terms: o['terms'] as String?,
          ),
      ],
      _List.progress => [
        for (final r in progress)
          r['onTheWay'] == true
              ? _OfferRow(
                  badge: ('…', 'SOON'),
                  gold: true,
                  title: '${r['name']}',
                  sub: r['creditsOn'] == null
                      ? r['note'] as String?
                      : 'Credited on ${tvsDate(r['creditsOn'])}',
                  right: '+${tvsCoins(r['amount'], r['currency'])}',
                )
              : _OfferRow(
                  badge: ('★', 'STEPS'),
                  gold: true,
                  title: '${r['name']}',
                  steps: ((r['steps'] as List?) ?? const []).cast<Map>(),
                  right: r['deadlineAt'] == null
                      ? r['reward'] as String?
                      : 'By ${tvsDate(r['deadlineAt'])}',
                ),
      ],
      _List.history => [
        for (final h in history.cast<Map>())
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${h['name']}',
                        style: tvsText(
                          colors.textPrimary,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        join([tvsDate(h['at']), h['note']]),
                        style: tvsText(colors.textSecondary, size: 12),
                      ),
                    ],
                  ),
                ),
                if (h['amount'] != null) ...[
                  Text(
                    tvsCoins(h['amount'], h['currency']),
                    style: tvsText(colors.textPrimary, weight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                ],
                TvsPill(h['status']),
              ],
            ),
          ),
      ],
    };

    const empty = {
      _List.coupons:
          'No coupons yet. Coupons given to you appear here and apply at checkout.',
      _List.discounts: 'No discounts running for you right now.',
      _List.rewards: 'No cashback or rewards running for you right now.',
      _List.progress:
          'Nothing in progress. Rewards with steps, and cashback on its way, show here.',
      _List.history: 'No rewards yet.',
    };

    final needsAddress = loc['hasAddress'] != true;
    final canVerify =
        !needsAddress && loc['source'] != 'home' && loc['verified'] != true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.place_outlined, size: 18, color: colors.auctionAccent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                needsAddress
                    ? 'Some offers depend on your area. Add your address to see them.'
                    : 'Offers for ${loc['label']} · '
                          '${loc['source'] == 'home' ? 'your verified home address' : 'your saved address'}',
                style: tvsText(colors.textSecondary, size: 12),
              ),
            ),
            if (needsAddress || canVerify)
              TextButton(
                onPressed: () => context.push(
                  needsAddress ? AppRoutes.buyerAddresses : AppRoutes.walletKyc,
                ),
                child: Text(needsAddress ? 'Add address' : 'Verify'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final l in _List.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      counts[l]! > 0 ? '${labels[l]} ${counts[l]}' : labels[l]!,
                    ),
                    selected: current == l,
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => setState(() => _list = l),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        rows.isEmpty
            ? TvsEmpty(empty[current]!, icon: Icons.local_offer_outlined)
            : TvsCard(children: rows),
      ],
    );
  }

  static String? _milestone(Map? m) {
    if (m == null) return null;
    final left = m['left'] as num? ?? 0;
    if (left == 0) return 'on your next payment';
    return '$left more payment${left > 1 ? 's' : ''} to go';
  }

  // The value of an offer, short: "10%" / "₹50" / "FREE", and what it is.
  static (String, String) _badge(
    Map? deal,
    String Function(Object?) money, {
    bool reward = false,
  }) {
    if (deal == null) return ('GIFT', '');
    final v = deal['value'];
    final n = num.tryParse('$v') ?? 0;
    final pct = '${n % 1 == 0 ? n.toInt() : n}%';
    return switch (deal['type']) {
      'PERCENT' => (pct, 'OFF'),
      'FIXED' => (money(v), 'OFF'),
      'FREE_SHIPPING' => ('FREE', 'DELIVERY'),
      'PERCENT_COINS' => (pct, 'BACK'),
      'COINS' => (money(v), reward ? 'COINS' : 'OFF'),
      'TIERED' => _tiered(deal, money),
      _ => ('%', ''),
    };
  }

  static (String, String) _tiered(Map deal, String Function(Object?) money) {
    final tiers = ((deal['tiers'] as List?) ?? const []).cast<Map>();
    final top = tiers
        .map((t) => num.tryParse('${t['value']}') ?? 0)
        .fold<num>(0, (a, b) => a > b ? a : b);
    return (deal['tierKind'] == 'PERCENT' ? '$top%' : money(top), 'UP TO');
  }
}

// One offer: value badge, name, one line of conditions, validity on the right.
class _OfferRow extends StatelessWidget {
  final (String, String) badge;
  final String title;
  final String? sub;
  final String? right;
  final String? warning;
  final String? terms;
  final List<Map>? steps;
  final bool gold;

  const _OfferRow({
    required this.badge,
    required this.title,
    this.sub,
    this.right,
    this.warning,
    this.terms,
    this.steps,
    this.gold = false,
  });

  void _showTerms(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tvsText(
                  context.colors.textPrimary,
                  size: 16,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(terms!, style: tvsText(context.colors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final off = warning != null;
    final gold = colors.auctionAccent;
    final (bg, fg) = off
        ? (colors.surfaceAlt, colors.textMuted)
        : this.gold
        ? (gold.withValues(alpha: 0.18), gold)
        : (colors.brand, colors.onBrand);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 48,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  badge.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tvsText(fg, size: 13, weight: FontWeight.w800),
                ),
                if (badge.$2.isNotEmpty)
                  Text(
                    badge.$2,
                    style: tvsText(fg, size: 8, weight: FontWeight.w700),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: tvsText(
                          off ? colors.textSecondary : colors.textPrimary,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (right != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        right!,
                        style: tvsText(colors.textSecondary, size: 11),
                      ),
                    ],
                  ],
                ),
                if (sub != null && sub!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      sub!,
                      style: tvsText(colors.textSecondary, size: 12),
                    ),
                  ),
                if (warning != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      warning!,
                      style: tvsText(colors.textMuted, size: 12),
                    ),
                  ),
                for (final s in steps ?? const <Map>[])
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          s['done'] == true
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 15,
                          color: s['done'] == true
                              ? colors.statusSuccess
                              : colors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${s['step']}'
                            '${s['target'] != null && s['done'] != true ? ' (${s['current']} of ${s['target']})' : ''}',
                            style:
                                tvsText(
                                  s['done'] == true
                                      ? colors.textMuted
                                      : colors.textSecondary,
                                  size: 12,
                                ).copyWith(
                                  decoration: s['done'] == true
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (terms != null && terms!.isNotEmpty)
                  InkWell(
                    onTap: () => _showTerms(context),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Terms',
                        style: tvsText(
                          colors.brand,
                          size: 12,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
