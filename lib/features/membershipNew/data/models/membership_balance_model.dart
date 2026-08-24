class BigodBalance {
  final double bigodBalance;
  final double tokenBalance;
  final String kycStatus;

  const BigodBalance({
    required this.bigodBalance,
    required this.tokenBalance,
    required this.kycStatus,
  });

  factory BigodBalance.fromJson(Map<String, dynamic> json) {
    final balances = (json['balances'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final tokenEntry = balances.firstWhere(
          (b) => b['coin'] == 'token',
      orElse: () => const {},
    );

    return BigodBalance(
      bigodBalance:
      (json['bigodBalance'] as num?)?.toDouble() ?? 0,
      tokenBalance:
      (tokenEntry['total_balance'] as num?)?.toDouble() ?? 0,
      kycStatus:
      json['kycStatus']?.toString() ?? 'NOT_INITIATED',
    );
  }
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