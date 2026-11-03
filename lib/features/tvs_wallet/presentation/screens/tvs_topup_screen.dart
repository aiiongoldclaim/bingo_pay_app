import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/idempotency_key_generator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../payment/presentation/widgets/stripe_checkout_view.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';
import '../../../scanner/presentation/widgets/review_payment_amount_section.dart';
import '../../../scanner/presentation/widgets/review_payment_metrics.dart';
import '../widgets/tvs_format.dart';
import '../widgets/tvs_ui.dart';

enum _Phase { entry, checkout, status }

// Add money by card: Stripe's page inside the app, then the top-up's status.
// Stripe's webhook credits the coins; this screen only asks how it went.
// Closes with `true` once anything may have changed.
class TvsTopupScreen extends StatefulWidget {
  final Map<String, dynamic>? wallet; // the home wallet

  const TvsTopupScreen({super.key, this.wallet});

  @override
  State<TvsTopupScreen> createState() => _TvsTopupScreenState();
}

class _TvsTopupScreenState extends State<TvsTopupScreen> {
  static const _quick = ['100', '500', '1000', '2000'];
  static const _poll = Duration(seconds: 3);
  static const _maxWait = Duration(minutes: 2);

  final _api = getIt<TvsQrDataSource>();
  final _amount = TextEditingController();

  _Phase _phase = _Phase.entry;
  String? _key; // one per top-up; a retry of the same amount reuses it
  Map<String, dynamic>? _topup;
  String? _error;
  bool _busy = false;
  Timer? _timer;
  DateTime? _since;

  String get _currency => '${widget.wallet?['currency'] ?? ''}';

  bool get _valid {
    final a = _amount.text;
    return RegExp(r'^\d{1,10}(\.\d{1,2})?$').hasMatch(a) &&
        (num.tryParse(a) ?? 0) > 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amount.dispose();
    super.dispose();
  }

  void _changed() => setState(() {
    _key = null; // a different amount is a different top-up
    _error = null;
  });

  Future<void> _start() async {
    setState(() => _busy = true);
    _key ??= IdempotencyKeyGenerator.generate().substring(0, 64);
    try {
      final t = await _api.startTopup(
        amount: _amount.text,
        idempotencyKey: _key!,
        walletUuid: widget.wallet?['uuid'] as String?,
      );
      final url = '${t['checkoutUrl'] ?? ''}';
      setState(() {
        _topup = t;
        if (url.startsWith('https://checkout.stripe.com/')) {
          _phase = _Phase.checkout;
        } else {
          _error =
              t['failureMessage'] as String? ??
              'The payment page could not be opened. Please try again.';
        }
      });
    } catch (e) {
      setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onReturn(StripeCheckoutReturn outcome) async {
    setState(() => _phase = _Phase.status);
    final uuid = '${_topup!['uuid']}';
    if (outcome == StripeCheckoutReturn.cancelled) {
      // The server credits it if it was in fact paid, so this is safe.
      try {
        final t = await _api.cancelTopup(uuid);
        if (mounted) setState(() => _topup = t);
      } catch (e) {
        if (mounted) setState(() => _error = _message(e));
      }
      return;
    }
    _since = DateTime.now();
    _check();
  }

  // Asks every few seconds until the top-up is settled, for up to two minutes.
  Future<void> _check() async {
    _timer?.cancel();
    try {
      final t = await _api.topup('${_topup!['uuid']}');
      if (!mounted) return;
      setState(() {
        _topup = t;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    }
    if (!mounted || _topup?['status'] != 'PENDING') return;
    if (DateTime.now().difference(_since!) < _maxWait) {
      _timer = Timer(_poll, _check);
    } else {
      setState(() {}); // stop: offer "Check again"
    }
  }

  void _again() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.entry;
      _topup = null;
      _key = null;
      _error = null;
    });
  }

  String _message(Object e) => ErrorHandler.mapObjectToFailure(e).message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopScope(
      canPop: false,
      // Leaving after a payment page opened: the wallet should reload.
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(_topup != null);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: const CustomAppBar(title: 'Add money'),
        body: SafeArea(
          child: switch (_phase) {
            _Phase.entry => _entry(colors),
            _Phase.checkout => StripeCheckoutView(
              checkoutUrl: '${_topup!['checkoutUrl']}',
              onReturn: _onReturn,
            ),
            _Phase.status => _status(colors),
          },
        ),
      ),
    );
  }

  Widget _entry(AppThemeColors colors) {
    final m = ReviewPaymentMetrics.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            children: [
              ReviewPaymentAmountSection(
                metrics: m,
                controller: _amount,
                currency: _currency,
                error: _error,
                autofocus: true,
                onChanged: (_) => _changed(),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in _quick)
                    ActionChip(
                      label: Text(tvsCoins(v, _currency).replaceAll('.00', '')),
                      onPressed: () {
                        _amount.text = v;
                        _changed();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'You get the same number of TVS Coins. Paid by card on Stripe’s secure page.',
                textAlign: TextAlign.center,
                style: tvsText(colors.textSecondary, size: 13),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            label: _valid
                ? 'Pay ${tvsCoins(_amount.text, _currency)} by card'
                : 'Continue to card payment',
            isLoading: _busy,
            onPressed: _valid && !_busy ? _start : null,
          ),
        ),
      ],
    );
  }

  Widget _status(AppThemeColors colors) {
    final t = _topup ?? const {};
    final status = t['status'];
    final waiting = status == 'PENDING';
    final stillWaiting = waiting && (_timer == null || !_timer!.isActive);
    final ok = status == 'COMPLETED';

    final (icon, color, title, text) = switch ((waiting, ok)) {
      (true, _) => (
        Icons.schedule_rounded,
        colors.statusWarning,
        'Confirming your payment…',
        stillWaiting
            ? 'This is taking longer than usual. Your coins are added as soon as the payment clears.'
            : 'This takes a few seconds. You can leave this screen; the coins arrive either way.',
      ),
      (_, true) => (
        Icons.check_circle_rounded,
        colors.statusSuccess,
        'Added ${tvsCoins(t['amount'], t['currency'])}',
        'The TVS Coins are in your wallet.',
      ),
      _ => (
        Icons.cancel_rounded,
        colors.error,
        'Top-up not completed',
        '${t['failureMessage'] ?? 'The payment didn’t go through.'}'
            '${t['refunded'] == true ? ' Your card was refunded.' : ''}',
      ),
    };

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          if (waiting && !stillWaiting)
            const SizedBox.square(
              dimension: 56,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          else
            Icon(icon, size: 64, color: color),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: tvsText(
              colors.textPrimary,
              size: 20,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? text,
            textAlign: TextAlign.center,
            style: tvsText(
              _error == null ? colors.textSecondary : colors.error,
              size: 14,
            ),
          ),
          const Spacer(),
          if (stillWaiting) ...[
            AppButton(
              label: 'Check again',
              variant: AppButtonVariant.outlined,
              onPressed: () {
                _since = DateTime.now();
                _check();
              },
            ),
            const SizedBox(height: 10),
          ],
          if (!waiting && !ok) ...[
            AppButton(
              label: 'Try again',
              variant: AppButtonVariant.outlined,
              onPressed: _again,
            ),
            const SizedBox(height: 10),
          ],
          AppButton(label: 'Done', onPressed: () => context.pop(true)),
        ],
      ),
    );
  }
}
