import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';
import 'tvs_format.dart';
import 'tvs_ui.dart';

// Invite & earn: my code, link and QR, what each side gets, friends who
// joined, and adding a code I was given.
class TvsInviteTab extends StatefulWidget {
  const TvsInviteTab({super.key});

  @override
  State<TvsInviteTab> createState() => _TvsInviteTabState();
}

class _TvsInviteTabState extends State<TvsInviteTab> {
  final _api = getIt<TvsQrDataSource>();
  final _code = TextEditingController();
  late Future<Map<String, dynamic>> _data = _api.referrals();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    setState(() => _busy = true);
    try {
      await _api.applyReferralCode(_code.text.trim().toUpperCase());
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Invite code added');
      setState(() => _data = _api.referrals());
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          ErrorHandler.mapObjectToFailure(e).message,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String? _benefit(Map? b) {
    if (b == null) return null;
    final unit = switch (b['type']) {
      'COINS' => ' TVS Coins',
      'PERCENT_COINS' => '% back',
      _ => '',
    };
    return '${b['value'] ?? ''}$unit';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FutureBuilder<Map<String, dynamic>>(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) {
          return const TvsEmpty('Could not load your invites.');
        }
        final d = snap.data;
        if (d == null) return const TvsListShimmer(rows: 3);

        final p = d['programme'] as Map?;
        final stats = (d['stats'] as Map?) ?? const {};
        final earned = ((stats['earned'] as List?) ?? const [])
            .cast<Map>()
            .map((e) => tvsCoins(e['amount'], e['currency']))
            .join(' + ');
        final friends = ((d['friends'] as List?) ?? const []).cast<Map>();
        final link = '${d['link'] ?? ''}';
        final cond = (p?['conditions'] as Map?) ?? const {};
        final friendGets = _benefit(p?['friendGets'] as Map?);
        final youGet = _benefit(p?['youGet'] as Map?);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TvsCard(
              padding: const EdgeInsets.all(16),
              children: [
                Column(
                  children: [
                    Text(
                      'Your invite code',
                      style: tvsText(colors.textSecondary, size: 13),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      '${d['code'] ?? ''}',
                      style: tvsText(
                        colors.brand,
                        size: 28,
                        weight: FontWeight.w800,
                      ).copyWith(letterSpacing: 4),
                    ),
                    const SizedBox(height: 12),
                    if (link.isNotEmpty) TvsQr(link, size: 140),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: link));
                              AppSnackbar.showSuccess(context, 'Link copied');
                            },
                            icon: const Icon(Icons.link_rounded, size: 18),
                            label: const Text('Copy link'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => SharePlus.instance.share(
                              ShareParams(
                                text:
                                    'Join me on TVS. Use my code ${d['code']}: $link',
                              ),
                            ),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p == null
                          ? 'Share your code. Invite rewards show here when a programme is running.'
                          : [
                              if (friendGets != null)
                                'Your friend gets $friendGets.',
                              if (youGet != null)
                                'You get $youGet'
                                    '${cond['kycRequired'] == true ? ' once they verify their identity' : ''}'
                                    '${cond['paymentsCount'] != null ? ' after their ${cond['paymentsCount']} payment(s)' : ''}.',
                              if (p['monthlyCap'] != null)
                                'Up to ${p['monthlyCap']} rewards a month.',
                            ].join(' '),
                      textAlign: TextAlign.center,
                      style: tvsText(colors.textSecondary, size: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat('Joined', '${stats['joined'] ?? 0}'),
                _Stat('Verified', '${stats['verified'] ?? 0}'),
                _Stat('Rewarded', '${stats['rewarded'] ?? 0}'),
                _Stat(
                  'Earned',
                  earned.isEmpty ? '0' : earned,
                  color: colors.statusSuccess,
                ),
              ],
            ),
            if (d['canAddCode'] == true) ...[
              const SizedBox(height: 16),
              Text(
                'Got an invite code?',
                style: tvsText(colors.textPrimary, weight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _code,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Code',
                        helperText:
                            'From a friend, brand or creator. Once, within 14 days of joining.',
                        helperMaxLines: 2,
                        filled: true,
                        fillColor: colors.surfaceAlt,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: SizedBox(
                      width: 96,
                      child: AppButton(
                        label: 'Add',
                        height: 46,
                        isLoading: _busy,
                        onPressed: _code.text.trim().length >= 3 && !_busy
                            ? _apply
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (d['joinedVia'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'You joined through ${d['joinedVia']['name']} '
                '(${'${d['joinedVia']['type']}'.toLowerCase()}).',
                style: tvsText(colors.textSecondary, size: 13),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Friends',
              style: tvsText(colors.textPrimary, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            friends.isEmpty
                ? const TvsEmpty(
                    'No one has joined with your code yet.',
                    icon: Icons.group_outlined,
                  )
                : TvsCard(
                    children: [
                      for (final f in friends)
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
                                      '${f['name']}',
                                      style: tvsText(
                                        colors.textPrimary,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Joined ${tvsDate(f['joinedAt'])} · '
                                      '${f['verified'] == true ? 'verified' : 'not verified yet'}',
                                      style: tvsText(
                                        colors.textSecondary,
                                        size: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (f['reward'] is Map)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TvsPill(f['reward']['status']),
                                    if (f['reward']['amount'] != null)
                                      Text(
                                        tvsCoins(
                                          f['reward']['amount'],
                                          f['reward']['currency'],
                                        ),
                                        style: tvsText(
                                          colors.textSecondary,
                                          size: 12,
                                        ),
                                      ),
                                  ],
                                )
                              else
                                Text(
                                  'waiting',
                                  style: tvsText(colors.textMuted, size: 12),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Stat(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tvsText(
                color ?? colors.textPrimary,
                size: 16,
                weight: FontWeight.w700,
              ),
            ),
            Text(label, style: tvsText(colors.textSecondary, size: 11)),
          ],
        ),
      ),
    );
  }
}
