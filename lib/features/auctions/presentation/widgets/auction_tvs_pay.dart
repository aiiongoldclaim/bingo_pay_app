import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/idempotency_key_generator.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';
import '../../../scanner/presentation/screens/wallet_mpin_screen.dart';
import '../../../tvs_wallet/presentation/widgets/tvs_format.dart';

// "Pay with TVS Coins" for an auction: a lot's bidding fee or a won lot. The
// quote has the checkout quote's shape ({canPay, reason, reasonCode, coins,
// wallet, pin}); `pay` sends {idempotencyKey, expectedCoins, pin?}.

// The option's line: the coins and the balance, or why it can't pay.
String tvsQuoteLine(Map<String, dynamic>? q) {
  if (q == null) return 'Checking your TVS Coins…';
  if (q['canPay'] != true) {
    return '${q['reason'] ?? 'Not available for this payment'}';
  }
  final c = (q['coins'] as Map?) ?? const {};
  final pin = (q['pin'] as Map?)?['required'] == true ? ' · MPIN needed' : '';
  return '${tvsCoins(c['total'], c['currency'])} · '
      'Balance ${tvsCoins(c['available'], c['currency'])}$pin';
}

// What the TVS option needs before it can pay, and the way there: verify
// (KYC) or add money. Nothing when it can pay. `onBack` re-quotes.
class TvsQuoteFix extends StatelessWidget {
  final Map<String, dynamic>? quote;
  final VoidCallback onBack;

  const TvsQuoteFix({super.key, required this.quote, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final q = quote;
    final (label, route, extra) = switch (q?['reasonCode']) {
      'KYC_REQUIRED' => ('Verify now', AppRoutes.walletKyc, null),
      'INSUFFICIENT_FUNDS' => ('Add money', AppRoutes.tvsTopup, q?['wallet']),
      _ => (null, null, null),
    };
    if (q == null || q['canPay'] == true || label == null) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () => context.push(route!, extra: extra).then((_) => onBack()),
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: Text(label),
      ),
    );
  }
}

// Pays the quoted coins, through the MPIN screen when the amount is over the
// PIN-free limit (creating an MPIN if there is none) — the checkout's TVS
// flow. True once paid. On QUOTE_CHANGED it calls `onQuoteChanged` so the new
// price is shown to confirm; a new price is a new payment, with a new key.
Future<bool> payAuctionWithTvs(
  BuildContext context, {
  required Map<String, dynamic>? quote,
  required Future<Map<String, dynamic>> Function(Map<String, dynamic> body)
  pay,
  required VoidCallback onQuoteChanged,
  required String subtitle,
  String? idempotencyKey,
  bool? needsPin,
  bool? isSet,
}) async {
  if (quote?['canPay'] != true) {
    AppSnackbar.showError(
      context,
      '${quote?['reason'] ?? 'Your TVS Coins are still being checked.'}',
    );
    return false;
  }
  final pin = quote!['pin'] as Map?;
  final coins = quote['coins'] as Map?;
  // One per payment; reused on retry so it is paid once.
  final key =
      idempotencyKey ?? IdempotencyKeyGenerator.generate().substring(0, 64);
  Map<String, dynamic> body([String? p]) => {
    'idempotencyKey': key,
    'expectedCoins': '${coins?['total']}',
    'pin': ?p,
  };

  Object? failure;
  if (needsPin ?? pin?['required'] == true) {
    final outcome = await runWithMpin(
      context,
      isSet: isSet ?? pin?['isSet'] != false,
      length: pin?['length'] as int? ?? 4,
      subtitle: subtitle,
      attempt: (p) => pay(body(p)),
    );
    if (outcome == null) return false;
    if (outcome.result != null) return true;
    failure = outcome.failure;
  } else {
    try {
      await pay(body());
      return true;
    } catch (e) {
      failure = e;
    }
  }

  if (!context.mounted) return false;
  if (failure is TvsQrException) {
    switch (failure.code) {
      // The PIN limit changed since the quote: ask for the MPIN now.
      case 'PIN_REQUIRED' || 'PIN_NOT_SET':
        return payAuctionWithTvs(
          context,
          quote: quote,
          pay: pay,
          onQuoteChanged: onQuoteChanged,
          subtitle: subtitle,
          idempotencyKey: key,
          needsPin: true,
          isSet: failure.code == 'PIN_REQUIRED',
        );
      case 'QUOTE_CHANGED':
        AppSnackbar.showError(context, failure.message);
        onQuoteChanged();
        return false;
    }
  }
  AppSnackbar.showError(
    context,
    failure is TvsQrException
        ? failure.message
        : 'The payment didn’t go through. You were not charged.',
  );
  return false;
}
