import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';
import '../cubit/tvs_wallet_state.dart';
import 'tvs_format.dart';
import 'tvs_ui.dart';

// The home wallet's statement, newest first, grouped by day. Older lines load
// as the wallet screen scrolls near the end ("Load more" if it can't scroll).
class TvsActivityList extends StatelessWidget {
  final TvsWalletState state;
  final VoidCallback onLoadMore;

  const TvsActivityList({
    super.key,
    required this.state,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (state.activity.isEmpty) {
      return const TvsEmpty(
        'No activity yet. Payments, top-ups and rewards show up here.',
        icon: Icons.receipt_long_outlined,
      );
    }
    // Newest first, so each day's lines are already together.
    final days = <String, List<Map<String, dynamic>>>{};
    for (final e in state.activity) {
      days.putIfAbsent(tvsDay(e['createdAt']), () => []).add(e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final day in days.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              day.key,
              style: tvsText(
                colors.textSecondary,
                size: 12,
                weight: FontWeight.w600,
              ),
            ),
          ),
          TvsCard(
            children: [
              for (final e in day.value)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: TvsEntryRow(e),
                ),
            ],
          ),
        ],
        if (state.nextCursor != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: state.loadingMore
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  : TextButton(
                      onPressed: onLoadMore,
                      child: const Text('Load more'),
                    ),
            ),
          ),
      ],
    );
  }
}

// One statement line: which way it went, what it was, and the signed amount.
class TvsEntryRow extends StatelessWidget {
  final Map<String, dynamic> e;

  const TvsEntryRow(this.e, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final credit = e['direction'] == 'CREDIT';
    final txn = e['transaction'] as Map?;
    final d = (txn?['details'] as Map?) ?? const {};
    final what =
        d['shop']?['name'] ??
        d['orderNumber'] ??
        d['to']?['name'] ??
        d['offer']?['name'] ??
        d['reason'] ??
        tvsHuman(txn?['type']);
    final gold = colors.auctionAccent;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: credit ? colors.statusSuccessSoft : colors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            credit ? Icons.south_west_rounded : Icons.north_east_rounded,
            size: 20,
            color: credit ? colors.statusSuccess : colors.textSecondary,
            semanticLabel: credit ? 'Received' : 'Spent',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${e['label'] ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tvsText(
                        colors.textPrimary,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (e['bucket'] == 'BONUS') ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'BONUS',
                        style: tvsText(gold, size: 9, weight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$what · ${tvsTime(e['createdAt'])}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tvsText(colors.textSecondary, size: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${credit ? '+' : '−'}${tvsCoins(e['amount'], e['currency'])}',
              style: tvsText(
                credit ? colors.statusSuccess : colors.textPrimary,
                weight: FontWeight.w700,
              ),
            ),
            if (e['balanceAfter'] != null)
              Text(
                'bal. ${tvsCoins(e['balanceAfter'])}',
                style: tvsText(colors.textMuted, size: 11),
              ),
          ],
        ),
      ],
    );
  }
}

// Bonus coins still to use, soonest expiry first.
class TvsBonusList extends StatefulWidget {
  final String? walletUuid;
  final String? currency;

  const TvsBonusList({super.key, this.walletUuid, this.currency});

  @override
  State<TvsBonusList> createState() => _TvsBonusListState();
}

class _TvsBonusListState extends State<TvsBonusList> {
  late final Future<List<dynamic>> _lots = getIt<TvsQrDataSource>().bonusLots(
    walletUuid: widget.walletUuid,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cur = widget.currency;

    return FutureBuilder<List<dynamic>>(
      future: _lots,
      builder: (context, snap) {
        if (snap.hasError) {
          return const TvsEmpty('Could not load your bonus coins.');
        }
        final lots = snap.data;
        if (lots == null) return const TvsListShimmer(rows: 3);
        if (lots.isEmpty) {
          return const TvsEmpty(
            'No bonus coins right now. See Offers & rewards for ways to earn some.',
            icon: Icons.card_giftcard_outlined,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TvsCard(
              children: [
                for (final l in lots.cast<Map>())
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${tvsCoins(l['remaining'], cur)} left',
                                style: tvsText(
                                  colors.textPrimary,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'of ${tvsCoins(l['amount'], cur)} bonus',
                                style: tvsText(colors.textSecondary, size: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          l['waitingForActivation'] == true
                              ? 'Starts when you activate'
                              : l['expiresAt'] == null
                              ? 'Never expires'
                              : 'Expires ${tvsDate(l['expiresAt'])}',
                          style: tvsText(colors.textSecondary, size: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Bonus is always spent first, soonest expiry first. It can’t be sent to others.',
              style: tvsText(colors.textMuted, size: 12),
            ),
          ],
        );
      },
    );
  }
}
