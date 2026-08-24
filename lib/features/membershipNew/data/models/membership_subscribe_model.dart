import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

num? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}

String _titleCase(String raw) => raw
    .split(RegExp(r'[_\s]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

// ---------------------------------------------------------------------------
// POST /api/v1/customer/membership/subscribe
//
// { data: { message, data: { subscription, payment } } }
// ---------------------------------------------------------------------------

class MembershipQuote extends Equatable {
  final CheckoutSubscriptionRef subscription;
  final CheckoutPayment payment;

  /// Backend ka message — "Payment quote created"
  final String message;

  const MembershipQuote({
    required this.subscription,
    required this.payment,
    this.message = '',
  });

  factory MembershipQuote.fromJson(
      Map<String, dynamic> json, {
        String message = '',
      }) => MembershipQuote(
    subscription: CheckoutSubscriptionRef.fromJson(
      json['subscription'] is Map
          ? Map<String, dynamic>.from(json['subscription'])
          : const {},
    ),
    payment: CheckoutPayment.fromJson(
      json['payment'] is Map
          ? Map<String, dynamic>.from(json['payment'])
          : const {},
    ),
    message: message,
  );

  @override
  List<Object?> get props => [subscription, payment, message];
}



// ---------------------------------------------------------------------------
// subscription (PENDING)
// ---------------------------------------------------------------------------

class CheckoutSubscriptionRef extends Equatable {
  final String uuid;
  final String reference;
  final String status; // PENDING

  const CheckoutSubscriptionRef({
    required this.uuid,
    required this.reference,
    required this.status,
  });

  String get statusLabel => _titleCase(status);

  bool get isPending => status.toUpperCase() == 'PENDING';

  factory CheckoutSubscriptionRef.fromJson(Map<String, dynamic> json) =>
      CheckoutSubscriptionRef(
        uuid: json['uuid']?.toString() ?? '',
        reference: json['reference']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [uuid, reference, status];
}

// ---------------------------------------------------------------------------
// payment quote (BIGOD)
// ---------------------------------------------------------------------------

class CheckoutPayment extends Equatable {
  final String paymentUuid;
  final String token;
  final String payUrl;

  /// "data:image/png;base64,...."
  final String qrCode;

  final num? amount; // 0.0014072
  final String currency; // BIGOD
  final num? priceUsd; // 89
  final num? tokenRate; // 63246.03
  final DateTime? expiresAt;

  const CheckoutPayment({
    required this.paymentUuid,
    required this.token,
    required this.payUrl,
    required this.qrCode,
    required this.amount,
    required this.currency,
    required this.priceUsd,
    required this.tokenRate,
    required this.expiresAt,
  });

  /// data: prefix hata ke pure base64
  String get qrBase64 {
    final i = qrCode.indexOf(',');
    return i == -1 ? qrCode : qrCode.substring(i + 1);
  }

  bool get hasQr => qrCode.trim().isNotEmpty;

  bool get isExpired =>
      expiresAt != null && !expiresAt!.isAfter(DateTime.now());

  Duration get timeLeft {
    if (expiresAt == null) return Duration.zero;
    final d = expiresAt!.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  /// "0.0014072 BIGOD"
  String get amountLabel =>
      amount == null ? '--' : '$amount ${currency.toUpperCase()}';

  /// "$89"
  String get priceUsdLabel => priceUsd == null ? '--' : '\$$priceUsd';

  /// "1 BIGOD = $63246.03"
  String get rateLabel {
    if (tokenRate == null) return '--';
    final r = tokenRate!.toStringAsFixed(4);
    return '1 ${currency.toUpperCase()} = \$$r';
  }

  factory CheckoutPayment.fromJson(Map<String, dynamic> json) =>
      CheckoutPayment(
        paymentUuid: json['paymentUuid']?.toString() ?? '',
        token: json['token']?.toString() ?? '',
        payUrl: json['payUrl']?.toString() ?? '',
        qrCode: json['qrCode']?.toString() ?? '',
        amount: _num(json['amount']),
        currency: json['currency']?.toString() ?? '',
        priceUsd: _num(json['priceUsd']),
        tokenRate: _num(json['tokenRate']),
        expiresAt: _date(json['expiresAt']),
      );

  @override
  List<Object?> get props => [
    paymentUuid,
    token,
    payUrl,
    amount,
    currency,
    priceUsd,
    tokenRate,
    expiresAt,
  ];
}
