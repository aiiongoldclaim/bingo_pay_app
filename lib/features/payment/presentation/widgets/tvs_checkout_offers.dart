import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../tvs_wallet/presentation/widgets/tvs_format.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'checkout_ui.dart';

const _when = {
  'INSTANT': 'right after you pay',
  'AFTER_DAYS': 'a few days after you pay',
  'AFTER_RETURN_WINDOW': 'after delivery and the return window',
};

List<Map> _list(Object? v) => [...?(v as List?)?.whereType<Map>()];

// "₹50.00" → "₹50", as the web shows savings.
String _amount(Object? v, Object? currency) =>
    tvsCoins(v, currency).replaceAll(RegExp(r'\.00$'), '');

// Under the TVS Wallet option (from the checkout quote): the MPIN-free limit,
// the offer applied with Change / Remove, the cashback this order earns and
// an offer one step away. Coupons are chosen in the "Apply coupon" sheet.
class TvsCheckoutOffers extends StatefulWidget {
  final Map<String, dynamic> quote;

  const TvsCheckoutOffers({super.key, required this.quote});

  @override
  State<TvsCheckoutOffers> createState() => _TvsCheckoutOffersState();
}

class _TvsCheckoutOffersState extends State<TvsCheckoutOffers> {
  String? _busy; // the offer choice being quoted

  Future<void> _pick(String offer) async {
    setState(() => _busy = offer);
    await context.read<PaymentMethodCubit>().chooseTvsOffer(offer);
    if (mounted) setState(() => _busy = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final q = widget.quote;
    final cur = (q['coins'] as Map?)?['currency'];
    final offers = _list(q['offers']);
    final applied = offers.where((x) => x['applied'] == true).firstOrNull;
    final rewards = _list(q['rewards']);
    final cashback = rewards.fold<num>(
      0,
      (sum, r) => sum + (num.tryParse('${r['amount']}') ?? 0),
    );
    final hint = _list(q['almost']).firstOrNull;
    final pin = q['canPay'] == true ? q['pin'] as Map? : null;

    final link = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pin?['limit'] != null) _PinNote(pin: pin!),
          _Line(
            icon: applied != null
                ? Icons.check_circle_rounded
                : Icons.local_offer_outlined,
            color: applied != null ? colors.statusSuccess : colors.textMuted,
            title: '${applied?['name'] ?? 'No offer applied'}',
            text: applied != null
                ? '${applied['best'] == true ? 'Best saving applied' : 'Applied'}'
                      '${applied['code'] != null ? ' · ${applied['code']}' : ''}'
                : offers.isEmpty
                ? 'Have a coupon code? Apply it here.'
                : '${offers.length} coupon${offers.length > 1 ? 's' : ''} available for this order',
            value: applied == null
                ? null
                : '−${_amount(applied['discount'], cur)}',
            valueColor: colors.statusSuccess,
          ),
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              if (_busy != null)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              if (applied == null && offers.isNotEmpty)
                TextButton(
                  style: link,
                  onPressed: _busy == null ? () => _pick('') : null,
                  child: const Text('Apply best'),
                ),
              TextButton(
                style: link,
                onPressed: () => showTvsCouponSheet(context),
                child: Text(applied != null ? 'Change' : 'Apply coupon'),
              ),
              if (applied != null)
                TextButton(
                  style: link,
                  onPressed: _busy == null ? () => _pick('NONE') : null,
                  child: const Text('Remove'),
                ),
            ],
          ),
          if (rewards.isNotEmpty)
            _Line(
              icon: Icons.toll_rounded,
              color: colors.statusWarning,
              title: 'Cashback in TVS Coins',
              text:
                  'Credited to your TVS Wallet ${_when[rewards.first['when']] ?? _when['INSTANT']}',
              value: '+${_amount(cashback, cur)}',
              valueColor: colors.statusWarning,
            ),
          if (hint != null)
            _Line(
              icon: Icons.lock_outline_rounded,
              color: colors.textMuted,
              title: '${hint['name']}',
              text: '${hint['hint']}',
            ),
        ],
      ),
    );
  }
}

// The MPIN-free limit and whether this payment needs the MPIN; locked after
// wrong tries, until when.
class _PinNote extends StatelessWidget {
  final Map pin;

  const _PinNote({required this.pin});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final limit = tvsCoins(pin['limit'], pin['currency']);
    final locked = pin['lockedUntil'] != null;
    final (icon, color, text) = locked
        ? (
            Icons.lock_rounded,
            colors.error,
            'MPIN locked after wrong tries until ${tvsTime(pin['lockedUntil'])}',
          )
        : pin['required'] != true
        ? (
            Icons.verified_user_outlined,
            colors.textSecondary,
            'No MPIN needed up to $limit',
          )
        : (
            Icons.lock_outline_rounded,
            colors.statusWarning,
            pin['isSet'] == true
                ? 'Over $limit — you’ll confirm with your MPIN'
                : 'Over $limit needs an MPIN — you’ll set one when you pay',
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: checkoutText(color, size: 12))),
        ],
      ),
    );
  }
}

// One summary line: an icon, a title over a quiet line, an amount.
class _Line extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;
  final String? value;
  final Color? valueColor;

  const _Line({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
    this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: checkoutText(
                    colors.textPrimary,
                    size: 13,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(text, style: checkoutText(colors.textSecondary, size: 12)),
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 8),
            Text(
              value!,
              style: checkoutText(
                valueColor ?? colors.textPrimary,
                size: 13,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// "Apply coupon": a code box (checked by quoting with it), the offers for
// this order as one choice (or none), then the ones one step away.
// shortcut: wallet coupons that don't fit this order (web's "other offers")
// aren't listed; add from GET offers if customers ask where a coupon went.
Future<void> showTvsCouponSheet(BuildContext context) {
  final cubit = context.read<PaymentMethodCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.colors.surface,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _CouponSheet()),
  );
}

class _CouponSheet extends StatefulWidget {
  const _CouponSheet();

  @override
  State<_CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends State<_CouponSheet> {
  late final _cubit = context.read<PaymentMethodCubit>();
  late final _code = TextEditingController(
    text: '${(_cubit.state.tvsQuote?['code'] as Map?)?['code'] ?? ''}',
  );
  String? _busy; // 'code', or the offer choice being quoted

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(String what, Future<void> Function() quote) async {
    setState(() => _busy = what);
    await quote();
    if (mounted) setState(() => _busy = null);
  }

  void _apply() {
    final code = _code.text.trim();
    if (code.isEmpty || _busy != null) return;
    _run('code', () => _cubit.applyTvsCode(code));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      builder: (context, state) {
        final q = state.tvsQuote ?? const <String, dynamic>{};
        final cur = (q['coins'] as Map?)?['currency'];
        final offers = _list(q['offers']);
        final almost = _list(q['almost']);
        final selected =
            offers.where((x) => x['applied'] == true).firstOrNull?['uuid'] ??
            'NONE';
        final result = q['code'] as Map?;
        final ok = result?['ok'] == true;
        final heading = checkoutText(
          colors.textSecondary,
          size: 12,
          weight: FontWeight.w600,
        );

        Widget choice(String value, String title, String? text, String? off) {
          final on = selected == value;
          return ListTile(
            onTap: _busy == null
                ? () => _run(value, () => _cubit.chooseTvsOffer(value))
                : null,
            contentPadding: EdgeInsets.zero,
            leading: _busy == value
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    on
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: on ? colors.brand : colors.textMuted,
                  ),
            title: Text(
              title,
              style: checkoutText(colors.textPrimary, weight: FontWeight.w600),
            ),
            subtitle: text == null
                ? null
                : Text(
                    text,
                    style: checkoutText(colors.textSecondary, size: 12),
                  ),
            trailing: off == null
                ? null
                : Text(
                    '−$off',
                    style: checkoutText(
                      colors.textPrimary,
                      weight: FontWeight.w700,
                    ),
                  ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Apply coupon',
                    style: checkoutText(
                      colors.textPrimary,
                      size: 18,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _code,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _apply(),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Enter coupon code',
                            filled: true,
                            fillColor: colors.surfaceAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 96,
                        child: AppButton(
                          label: 'Apply',
                          isLoading: _busy == 'code',
                          onPressed: _code.text.trim().isEmpty || _busy != null
                              ? null
                              : _apply,
                        ),
                      ),
                    ],
                  ),
                  if (result != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          ok ? Icons.check_rounded : Icons.close_rounded,
                          size: 16,
                          color: ok ? colors.statusSuccess : colors.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${result['code']} · ${result['message']}',
                            style: checkoutText(
                              ok ? colors.statusSuccess : colors.error,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // A failed quote has no offers, only why.
                  if (q['coins'] == null && q['reason'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${q['reason']}',
                      style: checkoutText(colors.error, size: 12),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text('AVAILABLE FOR THIS ORDER', style: heading),
                  if (offers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No coupons apply to this order yet.',
                        style: checkoutText(colors.textSecondary, size: 13),
                      ),
                    )
                  else ...[
                    for (final x in offers)
                      choice(
                        '${x['uuid']}',
                        '${x['name']}',
                        '${x['best'] == true ? 'Best saving · ' : ''}'
                            '${x['code'] != null ? 'Code ${x['code']}' : 'Applies automatically'}',
                        _amount(x['discount'], cur),
                      ),
                    choice('NONE', 'Don’t apply any offer', null, null),
                  ],
                  if (almost.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('ALMOST THERE', style: heading),
                    for (final x in almost)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${x['name']}',
                              style: checkoutText(colors.textPrimary, size: 13),
                            ),
                            Text(
                              '${x['hint']}',
                              style: checkoutText(
                                colors.statusWarning,
                                size: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'One offer per order.',
                    textAlign: TextAlign.center,
                    style: checkoutText(colors.textMuted, size: 12),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'Done',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
