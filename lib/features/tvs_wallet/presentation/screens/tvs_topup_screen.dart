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
  static const _maxWait = Duration(minutes: 10);
  static const _notOpened =
      'Couldn’t open the payment page. Please try again.';

  final _api = getIt<TvsQrDataSource>();
  final _amount = TextEditingController();

  _Phase _phase = _Phase.entry;
  String? _key; // one per top-up; a retry of the same amount reuses it
  Map<String, dynamic>? _topup;
  String? _error;
  bool _busy = false;
  bool _cameBack = false; // left Stripe's page without paying
  Timer? _timer;
  DateTime? _since;
  bool _gaveUp = false; // stopped asking: offer "Check again"
  // Stripe's "expired" webhook can beat the server's own cancel and leave
  // the code EXPIRED; the customer still pressed Cancel.
  bool _userCancelled = false;

  String get _currency => '${widget.wallet?['currency'] ?? ''}';

  bool get _whole => tvsWholeCurrency(_currency);

  bool get _valid => tvsAmountValid(_amount.text, whole: _whole);

  // Only ever open a Stripe Checkout page.
  String? get _checkoutUrl {
    final url = '${_topup?['checkoutUrl'] ?? ''}';
    return url.startsWith('https://checkout.stripe.com/') ? url : null;
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
      setState(() {
        _topup = t;
        if (t['status'] == 'PENDING' && _checkoutUrl != null) {
          _phase = _Phase.checkout;
        } else {
          // The server replays a key's top-up: a failed one needs a new key.
          if (t['status'] != 'PENDING') _key = null;
          _error = t['failureCode'] == 'GATEWAY_ERROR'
              ? _notOpened
              : t['failureMessage'] as String? ?? _notOpened;
        }
      });
    } on TvsQrException catch (e) {
      // A refusal leaves nothing pending under this key; the next try is new.
      _key = null;
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onReturn(StripeCheckoutReturn outcome) {
    setState(() {
      _phase = _Phase.status;
      _gaveUp = false;
      // Nothing is charged yet: they can go back and pay, or cancel.
      _cameBack = outcome == StripeCheckoutReturn.cancelled;
    });
    _since = DateTime.now();
    _check();
  }

  // The server credits it if it was in fact paid, so this is safe.
  Future<void> _cancel() async {
    setState(() => _busy = true);
    try {
      final t = await _api.cancelTopup('${_topup!['uuid']}');
      if (mounted) {
        setState(() {
          _topup = t;
          _userCancelled = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Asks every few seconds until the top-up is settled, for up to ten
  // minutes; once, for someone who backed out of Stripe's page.
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
    if (!mounted || _cameBack || _topup?['status'] != 'PENDING') return;
    if (DateTime.now().difference(_since!) < _maxWait) {
      _timer = Timer(_poll, _check);
    } else {
      setState(() => _gaveUp = true);
    }
  }

  void _again() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.entry;
      _topup = null;
      _key = null;
      _error = null;
      _cameBack = false;
      _userCancelled = false;
    });
  }

  String _message(Object e) => ErrorHandler.mapObjectToFailure(e).message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopScope(
      canPop: false,
      // Back on Stripe's page is backing out of the payment. Leaving after
      // a payment page opened: the wallet should reload.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_phase == _Phase.checkout) {
          _onReturn(StripeCheckoutReturn.cancelled);
        } else {
          context.pop(_topup != null);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        // maybePop, so the back arrow goes through the PopScope above.
        appBar: CustomAppBar(
          title: 'Add money',
          onBack: () => Navigator.maybePop(context),
        ),
        body: SafeArea(
          child: switch (_phase) {
            _Phase.entry => _entry(colors),
            _Phase.checkout => StripeCheckoutView(
              checkoutUrl: _checkoutUrl!,
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
                wholeNumbers: _whole,
                onChanged: (_) => _changed(),
              ),
              if (_valid) ...[
                const SizedBox(height: 4),
                Text(
                  '${tvsGroupDigits(_amount.text)} $_currency',
                  textAlign: TextAlign.center,
                  style: tvsText(colors.textSecondary, size: 13),
                ),
              ],
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
    final unfinished = waiting && _cameBack;
    final stillWaiting = waiting && !unfinished && _gaveUp;
    final ok = status == 'COMPLETED';
    final refunded = t['refunded'] == true;

    final (icon, color, title, text) = switch ((waiting, ok)) {
      (true, _) when unfinished => (
        Icons.warning_amber_rounded,
        colors.statusWarning,
        'Payment not finished',
        'Nothing has been charged. Go back to finish paying, or cancel this top-up.',
      ),
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
        refunded
            ? 'Payment refunded'
            : switch (_userCancelled ? 'CANCELLED' : t['failureCode']) {
                'EXPIRED' => 'This payment window closed',
                'CANCELLED' => 'Top-up cancelled',
                _ => 'Top-up not completed',
              },
        refunded
            ? 'Your card was charged, but the coins could not be added, so the full amount has been refunded. It can take 5–10 days to appear on your statement.'
            : '${t['failureMessage'] ?? 'Nothing was added and nothing has been charged.'}',
      ),
    };

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          if (waiting && !stillWaiting && !unfinished)
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
          if (unfinished) ...[
            if (_checkoutUrl != null) ...[
              AppButton(
                label: 'Back to payment',
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        _cameBack = false;
                        _phase = _Phase.checkout;
                      }),
              ),
              const SizedBox(height: 10),
            ],
            AppButton(
              label: 'Cancel top-up',
              variant: AppButtonVariant.outlined,
              isLoading: _busy,
              onPressed: _busy ? null : _cancel,
            ),
            const SizedBox(height: 10),
          ],
          if (stillWaiting) ...[
            AppButton(
              label: 'Check again',
              variant: AppButtonVariant.outlined,
              onPressed: () {
                _since = DateTime.now();
                setState(() => _gaveUp = false);
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
