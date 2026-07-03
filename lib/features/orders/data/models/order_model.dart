// lib/features/orders/data/models/order_model.dart

class OrderModel {
  final String id;
  final String uuid;
  final String orderNumber;
  final String? addressId;
  final String paymentStatus;
  final String paymentMethod;
  final String orderStatus;
  final int totalItems;
  final double subtotalAmount;
  final double discountAmount;
  final double taxAmount;
  final double shippingAmount;
  final double totalAmount;
  final String? notes;
  final DateTime placedAt;
  final DateTime? paidAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  // Only populated by the order-detail endpoint (GET /orders/{id}) — the
  // list endpoint (GET /orders) returns order summaries with no line items.
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.uuid,
    required this.orderNumber,
    this.addressId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.orderStatus,
    required this.totalItems,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.shippingAmount,
    required this.totalAmount,
    this.notes,
    required this.placedAt,
    this.paidAt,
    this.deliveredAt,
    this.cancelledAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>?;
    return OrderModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      addressId: json['addressId']?.toString(),
      paymentStatus: (json['paymentStatus'] as String?) ?? 'PENDING',
      paymentMethod: (json['paymentMethod'] as String?) ?? '',
      orderStatus: (json['orderStatus'] as String?) ?? 'PENDING',
      totalItems: _asInt(json['totalItems']) ?? 0,
      subtotalAmount: _asDouble(json['subtotalAmount']),
      discountAmount: _asDouble(json['discountAmount']),
      taxAmount: _asDouble(json['taxAmount']),
      shippingAmount: _asDouble(json['shippingAmount']),
      totalAmount: _asDouble(json['totalAmount']),
      notes: json['notes'] as String?,
      placedAt: _asDate(json['placedAt']) ?? DateTime.now(),
      paidAt: _asDate(json['paidAt']),
      deliveredAt: _asDate(json['deliveredAt']),
      cancelledAt: _asDate(json['cancelledAt']),
      items: rawItems == null
          ? const []
          : rawItems
              .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  bool get isDelivered => orderStatus.toUpperCase() == 'DELIVERED';
  bool get isCancelled => orderStatus.toUpperCase() == 'CANCELLED';
  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';

  String get displayOrderStatus => titleCaseStatus(orderStatus);
  String get displayPaymentStatus => titleCaseStatus(paymentStatus);

  String get displayPaymentMethod {
    switch (paymentMethod.toUpperCase()) {
      case 'WALLET':
        return 'Bingold Wallet';
      case 'RAZORPAY':
        return 'Card / UPI / Netbanking';
      case 'COD':
        return 'Cash on Delivery';
      default:
        return titleCaseStatus(paymentMethod);
    }
  }

  String get shortDate => _formatDate(placedAt);

  String get fullPlacedAt => formatDateTime(placedAt);

  String get formattedTotal => formatAmount(totalAmount);

  String formattedItemsLabel() => '$totalItems ${totalItems == 1 ? 'item' : 'items'}';
}

class OrderItemModel {
  final String id;
  final String productTitle;
  final String? productSlug;
  final String? sku;
  final int quantity;
  final double unitPrice;
  final double totalAmount;

  const OrderItemModel({
    required this.id,
    required this.productTitle,
    this.productSlug,
    this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productTitle: json['productTitle'] as String? ?? 'Product',
      productSlug: json['productSlug'] as String?,
      sku: json['sku'] as String?,
      quantity: _asInt(json['quantity']) ?? 1,
      unitPrice: _asDouble(json['unitPrice']),
      totalAmount: _asDouble(json['totalAmount']),
    );
  }

  String get formattedUnitPrice => formatAmount(unitPrice);
  String get formattedTotal => formatAmount(totalAmount);
}

// ── Formatting helpers ──────────────────────────────────────────────────────

String formatAmount(double value) => '\$${_formatPrice(value)}';

String titleCaseStatus(String value) {
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

String formatDateTime(DateTime date) {
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

// ── JSON parsing helpers ────────────────────────────────────────────────────
// The API sometimes returns numeric fields as JSON numbers and sometimes as
// strings (e.g. "totalAmount": "186628.8"), so values are parsed defensively.

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
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
