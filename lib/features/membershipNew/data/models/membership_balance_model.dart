import 'package:intl/intl.dart';

class BigodBalance {
  final double bigodBalance;
  final double tokenBalance;
  final String kycStatus;

  // The balance in dollars and in the user's own currency, display only; null
  // when the server has no price or rate.
  final double? usdValue;
  final String? localCurrency;
  final double? localValue;

  const BigodBalance({
    required this.bigodBalance,
    required this.tokenBalance,
    required this.kycStatus,
    this.usdValue,
    this.localCurrency,
    this.localValue,
  });

  /// "≈ $12.34 · ≈ ₹1,025.10" as the website shows it: the local part only
  /// for a non-USD currency, null with no USD value.
  String? get valueLine {
    final usd = usdValue;
    if (usd == null) return null;
    final currency = localCurrency;
    final local = localValue;
    final usdText = '≈ ${_money(usd, 'USD')}';
    return currency == null || currency == 'USD' || local == null
        ? usdText
        : '$usdText · ≈ ${_money(local, currency)}';
  }

  factory BigodBalance.fromJson(Map<String, dynamic> json) {
    final balances = (json['balances'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final tokenEntry = balances.firstWhere(
          (b) => b['coin'] == 'token',
      orElse: () => const {},
    );

    final local = json['local'] is Map ? json['local'] as Map : const {};

    return BigodBalance(
      usdValue: _number(json['usdValue']),
      localCurrency: local['currency']?.toString(),
      localValue: _number(local['value']),
      bigodBalance:
      (json['bigodBalance'] as num?)?.toDouble() ?? 0,
      tokenBalance:
      (tokenEntry['total_balance'] as num?)?.toDouble() ?? 0,
      kycStatus:
      json['kycStatus']?.toString() ?? 'NOT_INITIATED',
    );
  }
}

double? _number(Object? value) => num.tryParse('${value ?? ''}')?.toDouble();

// "$12.34", "₹1,025.10"; sub-cent amounts keep four places so a small balance
// doesn't read as nothing (same rule as the website).
String _money(double value, String currency) {
  var symbol = NumberFormat.simpleCurrency(
    locale: 'en_US',
    name: currency,
  ).currencySymbol;
  // Dart writes SGD, CAD, AUD… as a bare "$": name them, as the website does.
  if (symbol == r'$' && currency != 'USD') symbol = '$currency ';
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: symbol,
    decimalDigits: value > 0 && value < 0.01 ? 4 : 2,
  ).format(value);
}

class BigodConfirmResult {
  final String paymentUuid;
  final double amount;
  final String currency;
  final String subscriptionUuid;
  final String subscriptionStatus;
  final String planName;

  const BigodConfirmResult({
    required this.paymentUuid,
    required this.amount,
    required this.currency,
    required this.subscriptionUuid,
    required this.subscriptionStatus,
    required this.planName,
  });

  factory BigodConfirmResult.fromJson(
      Map<String, dynamic> json,
      ) {
    final sub = Map<String, dynamic>.from(
      json['subscription'] ?? {},
    );

    return BigodConfirmResult(
      paymentUuid:
      json['paymentUuid']?.toString() ?? '',
      amount:
      (json['amount'] as num?)?.toDouble() ?? 0,
      currency:
      json['currency']?.toString() ?? 'BIGOD',
      subscriptionUuid:
      sub['uuid']?.toString() ?? '',
      subscriptionStatus:
      sub['status']?.toString() ?? '',
      planName:
      sub['planName']?.toString() ?? '',
    );
  }
}