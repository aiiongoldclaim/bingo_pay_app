import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../payment/data/stripe_payment_datasource.dart';
import '../../../tvs_wallet/presentation/widgets/tvs_format.dart';
import '../../../tvs_wallet/presentation/widgets/tvs_ui.dart';
import '../../data/datasources/auctions_remote_datasources.dart';
import '../../domain/entities/allotment_payment_entity.dart';
import '../../domain/entities/auction_detail_entity.dart';
import '../screens/deposit_checkout_screen.dart';
import 'auction_tvs_pay.dart';

enum _Method { crypto, card, tvs, bigod }

// The advance bidding fee ("token money"), asked for before a bidder's first
// bid on a lot that carries one. Every amount comes from the server. Resolves
// true once the fee is paid. Port of the web's DepositPaymentModal.
class DepositPaymentSheet extends StatefulWidget {
  final String auctionUuid;
  final AuctionBidFeeEntity fee;

  const DepositPaymentSheet({
    super.key,
    required this.auctionUuid,
    required this.fee,
  });

  static Future<bool> show(
    BuildContext context, {
    required String auctionUuid,
    required AuctionBidFeeEntity fee,
  }) async {
    final paid = await showAppSheet<bool>(
      context: context,
      builder: (_) => DepositPaymentSheet(auctionUuid: auctionUuid, fee: fee),
    );
    return paid == true;
  }

  @override
  State<DepositPaymentSheet> createState() => _DepositPaymentSheetState();
}

class _DepositPaymentSheetState extends State<DepositPaymentSheet> {
  final _api = getIt<AuctionsRemoteDatasources>();

  _Method? _method;
  // Card and crypto only when the server offers them, as at checkout.
  bool _cardOk = false;
  bool _cryptoOk = false;
  // TVS is hidden only when it is switched off for this account, as at
  // checkout; any other failure shows it with the reason.
  bool _tvsOk = true;
  Map<String, dynamic>? _tvsQuote;
  AllotmentPaymentEntity? _bigodQuote;
  String? _bigodError;
  double? _bigodBalance;
  bool _busy = false;

  String get _feeText => tvsCoins(widget.fee.amount, widget.fee.currency);

  @override
  void initState() {
    super.initState();
    getIt<StripePaymentDataSource>()
        .availableMethods()
        .then((m) {
          if (!mounted) return;
          setState(() {
            _cardOk = m.contains('STRIPE');
            _cryptoOk = m.contains('NOWPAYMENTS');
          });
        })
        .catchError((_) {});
    _loadTvsQuote();
  }

  // Moves nothing, so it is asked for freely (on open, after QUOTE_CHANGED,
  // after a top-up).
  Future<void> _loadTvsQuote() async {
    setState(() => _tvsQuote = null);
    final q = await loadTvsQuote(
      () => _api.tvsDepositQuote(widget.auctionUuid),
    );
    if (!mounted) return;
    setState(() {
      _tvsQuote = q;
      _tvsOk = q != null;
      if (!_tvsOk && _method == _Method.tvs) _method = null;
    });
  }

  // Each BIGOD quote mints a single-use token and cancels the last, so it is
  // only asked for once BIGOD is picked.
  Future<void> _loadBigod() async {
    setState(() {
      _bigodQuote = null;
      _bigodError = null;
    });
    _api.getBigodTokenBalance().then(
      (b) => mounted ? setState(() => _bigodBalance = b) : null,
      onError: (_) {},
    );
    try {
      final q = (await _api.depositBigodQuote(widget.auctionUuid)).toEntity();
      if (!mounted) return;
      setState(() {
        if (q.token.isEmpty) {
          _bigodError = 'BIGOD payment is unavailable right now.';
        } else {
          _bigodQuote = q;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(
          () => _bigodError = ErrorHandler.mapObjectToFailure(e).message,
        );
      }
    }
  }

  void _choose(_Method m) {
    if (_busy) return;
    setState(() => _method = m);
    if (m == _Method.bigod && _bigodQuote == null) _loadBigod();
  }

  bool get _bigodShort =>
      _bigodQuote != null &&
      _bigodBalance != null &&
      _bigodBalance! < _bigodQuote!.amount;

  void _paid(String message) {
    AppSnackbar.showSuccess(context, message);
    Navigator.pop(context, true);
  }

  Future<void> _pay() async {
    setState(() => _busy = true);
    try {
      switch (_method) {
        case _Method.crypto || _Method.card:
          await _payOnGateway(crypto: _method == _Method.crypto);
        case _Method.tvs:
          final ok = await payAuctionWithTvs(
            context,
            quote: _tvsQuote,
            pay: (body) => _api.tvsDepositPay(widget.auctionUuid, body),
            onQuoteChanged: _loadTvsQuote,
            subtitle: 'Pay the token money for this lot',
          );
          if (ok && mounted) {
            _paid('Token money paid with TVS Coins — placing your bid.');
          }
        case _Method.bigod:
          await _payBigod();
        case null:
          break;
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _payOnGateway({required bool crypto}) async {
    try {
      final intent = await _api.depositGatewayIntent(
        widget.auctionUuid,
        crypto: crypto,
      );
      // Only ever follow the gateway's own page — never an arbitrary url.
      final url = Uri.tryParse(intent.checkoutUrl);
      final isGatewayPage = crypto
          ? url != null &&
                url.isScheme('https') &&
                (url.host == 'nowpayments.io' ||
                    url.host.endsWith('.nowpayments.io'))
          : intent.checkoutUrl.startsWith('https://checkout.stripe.com/');
      if (!isGatewayPage) throw const FormatException('No checkout url');
      if (!mounted) return;
      final paid = await DepositCheckoutScreen.open(
        context,
        intent,
        isCrypto: crypto,
      );
      if (paid && mounted) _paid('Token money received — placing your bid.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        e is FormatException
            ? 'Could not start payment. Please try again.'
            : ErrorHandler.mapObjectToFailure(e).message,
      );
    }
  }

  Future<void> _payBigod() async {
    final quote = _bigodQuote;
    if (quote == null) return;
    if (quote.isExpired) {
      AppSnackbar.showError(
        context,
        'The BIGOD price was refreshed. Please confirm the new amount.',
      );
      await _loadBigod();
      return;
    }
    try {
      await _api.confirmBigodPayment(quote.token);
      if (mounted) _paid('Token money paid — placing your bid.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, ErrorHandler.mapObjectToFailure(e).message);
      // The token is spent or stale either way: price it again.
      await _loadBigod();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fee = widget.fee;
    final q = _bigodQuote;
    final coins = _tvsQuote?['coins'] as Map?;

    final (label, enabled) = switch (_method) {
      null => ('Choose how to pay', false),
      _Method.crypto => ('Pay $_feeText with crypto', true),
      _Method.card => ('Pay $_feeText by card', true),
      _Method.tvs => (
        coins == null
            ? 'Pay with TVS Coins'
            : 'Pay ${tvsCoins(coins['total'], coins['currency'])} with TVS Coins',
        _tvsQuote?['canPay'] == true,
      ),
      _Method.bigod => (
        q == null ? 'Pay with BIGOD' : 'Pay ${_bigod(q.amount)} BIGOD',
        q != null && !_bigodShort,
      ),
    };

    final bigodLine = _method != _Method.bigod
        ? 'From your BinGold wallet — paid instantly.'
        : _bigodError ??
              (q == null
                  ? 'Getting today’s BIGOD price…'
                  : '${_bigod(q.amount)} BIGOD · Balance '
                        '${_bigodBalance == null ? 'unavailable' : _bigod(_bigodBalance!)}'
                        '${_bigodShort ? ' — not enough' : ''}');

    return AppSheetShell(
      title: 'Pay token money to participate',
      footer: AppSheetButton(
        label: label,
        isLoading: _busy,
        onTap: enabled ? _pay : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.brandSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Token money (${fee.percentText}% of the '
                        '${tvsCoins(fee.baseAmount, fee.currency)} base price)',
                        style: tvsText(colors.textSecondary, size: 13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _feeText,
                      style: tvsText(
                        colors.textPrimary,
                        size: 18,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final line in [
                  'Paid once for this lot — then bid as many times as you like.',
                  'If you win, $_feeText is deducted and you pay only the '
                      'remaining amount.',
                  'If you don’t win, it will be refunded. It is kept only if '
                      'you win and don’t pay the remaining amount in time.',
                ])
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: colors.brand,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            line,
                            style: tvsText(colors.textSecondary, size: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose how to pay',
            style: tvsText(colors.textPrimary, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TvsCard(
            children: [
              if (_cryptoOk)
                _tile(
                  _Method.crypto,
                  Icons.currency_bitcoin,
                  'Pay with crypto',
                  'NOWPayments — pick a coin on the next page.',
                ),
              if (_cardOk)
                _tile(
                  _Method.card,
                  Icons.credit_card_outlined,
                  'Pay by card',
                  'Stripe — Visa, Mastercard, Amex and more.',
                ),
              if (_tvsOk)
                _tile(
                  _Method.tvs,
                  Icons.toll_rounded,
                  'Pay with TVS Coins',
                  tvsQuoteLine(_tvsQuote),
                ),
              _tile(
                _Method.bigod,
                Icons.account_balance_wallet_outlined,
                'Pay with BIGOD',
                bigodLine,
              ),
            ],
          ),
          if (_method == _Method.tvs)
            TvsQuoteFix(quote: _tvsQuote, onBack: _loadTvsQuote),
          if (fee.currency != 'USD' &&
              (_method == _Method.card || _method == _Method.crypto)) ...[
            const SizedBox(height: 8),
            Text(
              'Card and crypto payments are charged in USD at today’s rate.',
              style: tvsText(colors.textMuted, size: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile(_Method m, IconData icon, String title, String subtitle) {
    final colors = context.colors;
    final selected = _method == m;
    return ListTile(
      onTap: () => _choose(m),
      selected: selected,
      selectedTileColor: colors.brandSoft.withValues(alpha: 0.5),
      leading: Icon(icon, color: colors.brand),
      title: Text(
        title,
        style: tvsText(colors.textPrimary, weight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: tvsText(colors.textSecondary, size: 12)),
      trailing: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
        color: selected ? colors.brand : colors.textMuted,
      ),
    );
  }
}

String _bigod(num value) => value.toStringAsFixed(value < 1 ? 8 : 4);
