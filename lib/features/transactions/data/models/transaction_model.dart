// lib/features/transactions/data/models/transaction_model.dart

class TransactionModel {
  final String uuid;
  final double amount;
  final String currency;
  final String status; // PENDING | SUCCESS | FAILED | REFUNDED ...
  final String gateway; // RAZORPAY | PAYTM | WALLET ...
  final String? gatewayPaymentId;
  final DateTime? paidAt;
  final DateTime createdAt;
  final TransactionOrderRef? order;

  const TransactionModel({
    required this.uuid,
    required this.amount,
    required this.currency,
    required this.status,
    required this.gateway,
    this.gatewayPaymentId,
    this.paidAt,
    required this.createdAt,
    this.order,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawOrder = json['order'];
    return TransactionModel(
      uuid: json['uuid'] as String? ?? '',
      amount: _asDouble(json['amount']),
      currency: (json['currency'] as String?) ?? 'INR',
      status: (json['status'] as String?) ?? 'PENDING',
      gateway: (json['gateway'] as String?) ?? '',
      gatewayPaymentId: json['gatewayPaymentId'] as String?,
      paidAt: _asDate(json['paidAt']),
      createdAt: _asDate(json['createdAt']) ?? DateTime.now(),
      order: rawOrder is Map<String, dynamic>
          ? TransactionOrderRef.fromJson(rawOrder)
          : null,
    );
  }

  bool get isSuccess => const {
    'SUCCESS',
    'PAID',
    'COMPLETED',
  }.contains(status.toUpperCase());
  bool get isFailed =>
      const {'FAILED', 'CANCELLED'}.contains(status.toUpperCase());
  bool get isPending => status.toUpperCase() == 'PENDING';

  String get displayStatus => _titleCase(status);

  String get displayGateway {
    switch (gateway.toUpperCase()) {
      case 'RAZORPAY':
        return 'Razorpay';
      case 'PAYTM':
        return 'Paytm';
      case 'WALLET':
        return 'Bingold Wallet';
      case '':
        return 'Payment gateway';
      default:
        return _titleCase(gateway);
    }
  }

  String get formattedAmount => '${_currencySymbol(currency)}${_formatPrice(amount)}';

  String get shortDate => _formatDate(createdAt);

  String get fullDateTime => _formatDateTime(createdAt);
}

class TransactionOrderRef {
  final String uuid;
  final String orderNumber;
  final String orderStatus;
  final String paymentStatus;

  const TransactionOrderRef({
    required this.uuid,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentStatus,
  });

  factory TransactionOrderRef.fromJson(Map<String, dynamic> json) {
    return TransactionOrderRef(
      uuid: json['uuid'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      orderStatus: (json['orderStatus'] as String?) ?? 'PENDING',
      paymentStatus: (json['paymentStatus'] as String?) ?? 'PENDING',
    );
  }
}

// ── Formatting helpers ──────────────────────────────────────────────────────

String _currencySymbol(String currency) {
  switch (currency.toUpperCase()) {
    case 'INR':
      return '\$';
    case 'USD':
      return '\$';
    default:
      return '$currency ';
  }
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value
      .split('_')
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatDateTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${_formatDate(date)} · $hour:$minute $period';
}

String _formatPrice(double price) {
  return price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

double _asDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

DateTime? _asDate(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
