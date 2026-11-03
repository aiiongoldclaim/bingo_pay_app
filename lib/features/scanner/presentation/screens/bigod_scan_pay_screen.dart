import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../payment/data/bigod_payment_datasource.dart';
import '../widgets/review_payment_merchant_card.dart';
import '../widgets/review_payment_metrics.dart';
import '../widgets/review_payment_pay_bar.dart';

// A BIGOD checkout QR from the website: shows what is being paid, then pays
// it. The server prices it and moves the money; only the account that made
// the payment on the website can pay it (others get a 403).
class BigodScanPayScreen extends StatefulWidget {
  final String token;

  const BigodScanPayScreen({super.key, required this.token});

  @override
  State<BigodScanPayScreen> createState() => _BigodScanPayScreenState();
}

// Why a payment that isn't PENDING can't be paid from here.
const _statusNotes = {
  'PROCESSING': 'This payment is being processed.',
  'PAID': 'This payment has already been made.',
  'FAILED': 'This payment failed. Start again on the checkout page.',
  'EXPIRED': 'This QR has expired. Start again on the checkout page.',
  'RECONCILING': 'This payment is being checked. Please wait a few minutes.',
};

// Up to 8 decimals, no trailing zeros: 2.40963855, 12.5, 300.
String formatBigod(Object? v) {
  final n = num.tryParse('${v ?? ''}');
  if (n == null) return '—';
  return n.toStringAsFixed(8).replaceFirst(RegExp(r'\.?0+$'), '');
}

class _BigodScanPayScreenState extends State<BigodScanPayScreen> {
  final _api = getIt<BigodPaymentDataSource>();

  Map<String, dynamic>? _intent; // from /payments/bigod/resolve-token
  String? _error;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // The order's price as the website showed it: in the payer's currency when
  // the server knows it, else USD. Null from an older server (BIGOD only).
  String? get _price {
    final local = _intent?['local'] as Map?;
    final total = num.tryParse(
      '${local?['total'] ?? (_intent?['usd'] as Map?)?['total']}',
    );
    if (total == null) return null;
    return NumberFormat.simpleCurrency(
      name: local == null ? 'USD' : '${local['currency']}',
    ).format(total);
  }

  Future<void> _load() async {
    try {
      final intent = await _api.resolveToken(widget.token);
      if (!mounted) return;
      setState(() {
        // A shop's own token in a link has no amount to pay.
        final payment = intent['type'] == 'PAYMENT_INTENT';
        _intent = payment ? intent : null;
        _error = payment ? null : 'This QR is not a BIGOD payment.';
      });
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    }
  }

  List<Map<String, dynamic>> _list(String key) =>
      (_intent?[key] as List? ?? const []).cast<Map<String, dynamic>>();

  String get _shops =>
      _list('vendors').map((v) => '${v['shopName'] ?? 'Shop'}').join(', ');

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      final r = await _api.payToken(widget.token);
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Payment successful');
      final bigod = '${formatBigod(r['amount'])} BIGOD';
      final fiat = _price;
      context.pushReplacement(
        AppRoutes.transferSuccess,
        extra: {
          'merchantName': _shops,
          'amount': fiat ?? bigod,
          'caption': fiat == null ? null : 'Paid $bigod',
          'reference': r['order']?['orderNumber'] ?? r['reference'],
          'method': 'BIGOD',
        },
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, _message(e));
      _load(); // show where it stands now: still payable, paid or expired
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  String _message(Object e) => ErrorHandler.mapObjectToFailure(e).message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final intent = _intent;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CustomAppBar(title: 'Scan & Pay'),
      body: SafeArea(
        bottom: false,
        child: intent == null
            ? (_error == null
                  ? const AppLoader()
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                    ))
            : _body(context, intent),
      ),
    );
  }

  Widget _body(BuildContext context, Map<String, dynamic> intent) {
    final colors = context.colors;
    final m = ReviewPaymentMetrics.of(context);
    final status = '${intent['status']}';
    final amount = formatBigod(intent['amount']);
    final fiat = _price;
    final vendors = _list('vendors');
    final expires = DateTime.tryParse('${intent['expiresAt']}')?.toLocal();
    final muted = AppTextStyles.bodySmall.copyWith(
      color: colors.textSecondary,
      fontFamily: 'Inter',
      fontSize: m.helperSize + 2,
    );

    Widget line(String left, String right) => Padding(
      padding: EdgeInsets.only(bottom: m.gapXs),
      child: Row(
        children: [
          Expanded(child: Text(left, style: muted)),
          Text(right, style: muted.copyWith(color: colors.textPrimary)),
        ],
      ),
    );

    Widget column(List<Widget> children) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: m.pageHPad,
              vertical: m.gapLg,
            ),
            child: column([
              ReviewPaymentMerchantCard(
                metrics: m,
                name: _shops,
                subtitle: 'Pay in BIGOD',
                initials: _shops
                    .split(RegExp(r'[\s,]+'))
                    .where((w) => w.isNotEmpty)
                    .take(2)
                    .map((w) => w[0])
                    .join()
                    .toUpperCase(),
              ),
              SizedBox(height: m.gapLg),
              Text(
                fiat ?? '$amount BIGOD',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayLarge.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: m.amountSize * 1.2,
                ),
              ),
              if (fiat != null) ...[
                SizedBox(height: m.gapXs),
                Text(
                  '$amount BIGOD',
                  textAlign: TextAlign.center,
                  style: muted,
                ),
              ],
              if (expires != null && status == 'PENDING') ...[
                SizedBox(height: m.gapSm),
                Text(
                  'Valid until '
                  '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(expires))}',
                  textAlign: TextAlign.center,
                  style: muted,
                ),
              ],
              if (_statusNotes[status] case final note?) ...[
                SizedBox(height: m.gapSm),
                Text(
                  note,
                  textAlign: TextAlign.center,
                  style: muted.copyWith(
                    color: status == 'PAID'
                        ? colors.textSecondary
                        : colors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              SizedBox(height: m.gapLg),
              for (final i in _list('items'))
                line('${i['productTitle']}', '× ${i['quantity']}'),
              // A cart from several shops pays each its own share.
              if (vendors.length > 1) ...[
                SizedBox(height: m.gapSm),
                for (final v in vendors)
                  line('${v['shopName']}', '${formatBigod(v['amount'])} BIGOD'),
              ],
            ]),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            m.pageHPad,
            m.gapSm,
            m.pageHPad,
            m.gapSm,
          ),
          child: SafeArea(
            top: false,
            child: column([
              Text(
                'Paying from your BIGOD wallet',
                textAlign: TextAlign.center,
                style: muted,
              ),
              SizedBox(height: m.gapSm),
              ReviewPaymentPayBar(
                metrics: m,
                label: 'Pay $amount BIGOD',
                isLoading: _paying,
                isEnabled: status == 'PENDING' && !_paying,
                onPay: _pay,
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
