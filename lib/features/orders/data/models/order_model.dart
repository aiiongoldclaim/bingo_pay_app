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
  final OrderTrackingModel? tracking;

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
    this.tracking,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>?;
    final trackingData = _asMap(json['tracking']);
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
      tracking: trackingData != null ? OrderTrackingModel.fromJson(trackingData) : null,
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

  String formattedItemsLabel() =>
      '$totalItems ${totalItems == 1 ? 'item' : 'items'}';

  String? get previewImageUrl {
    for (final item in items) {
      final imageUrl = item.imageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) return imageUrl;
    }
    return null;
  }
}

class OrderItemModel {
  final String id;
  final String productTitle;
  final String? productId;
  final String? productUuid;
  final String? productSlug;
  final String? sku;
  final String? imageUrl;
  final String? brandName;
  final String? vendorName;
  final String? variantName;
  final String? color;
  final String? size;
  final int quantity;
  final double unitPrice;
  final double totalAmount;

  const OrderItemModel({
    required this.id,
    required this.productTitle,
    this.productId,
    this.productUuid,
    this.productSlug,
    this.sku,
    this.imageUrl,
    this.brandName,
    this.vendorName,
    this.variantName,
    this.color,
    this.size,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product =
        _asMap(json['product']) ??
        _asMap(json['productDetails']) ??
        _asMap(json['productData']);
    final variant =
        _asMap(json['variant']) ??
        _asMap(json['productVariant']) ??
        _asMap(json['variantDetails']);
    final brand = _asMap(product?['brand']) ?? _asMap(json['brand']);
    final vendor = _asMap(product?['vendor']) ?? _asMap(json['vendor']);
    final variantAttributes =
        _asMap(variant?['attributes']) ?? _asMap(json['variantAttributes']);

    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: _firstString([json['productId'], product?['id']]),
      productUuid: _firstString([json['productUuid'], product?['uuid']]),
      productTitle:
          _firstString([
            json['productTitle'],
            json['title'],
            json['name'],
            product?['title'],
            product?['name'],
            product?['productName'],
          ]) ??
          'Product',
      productSlug: _firstString([json['productSlug'], product?['slug']]),
      sku: _firstString([json['sku'], variant?['sku']]),
      imageUrl: _firstString([
        json['imageUrl'],
        json['imageURL'],
        json['image'],
        json['thumbnailUrl'],
        json['thumbnailURL'],
        json['thumbnail'],
        json['productImageUrl'],
        json['productImage'],
        _extractMediaUrl(json),
        _extractMediaUrl(product),
        variant?['imageUrl'],
        variant?['image'],
      ]),
      brandName: _firstString([
        json['brandName'],
        product?['brandName'],
        brand?['name'],
      ]),
      vendorName: _firstString([
        json['vendorName'],
        json['sellerName'],
        product?['vendorName'],
        vendor?['businessName'],
        vendor?['storeName'],
        vendor?['name'],
        vendor?['email'],
      ]),
      variantName: _firstString([
        json['variantName'],
        variant?['name'],
        variant?['title'],
      ]),
      color: _firstString([
        json['color'],
        json['colorName'],
        variant?['color'],
        variant?['colorName'],
        variantAttributes?['color'],
        variantAttributes?['Color'],
      ]),
      size: _firstString([
        json['size'],
        json['sizeName'],
        variant?['size'],
        variant?['sizeName'],
        variantAttributes?['size'],
        variantAttributes?['Size'],
      ]),
      quantity: _asInt(json['quantity']) ?? 1,
      unitPrice: _asDouble(json['unitPrice']),
      totalAmount: _asDouble(json['totalAmount']),
    );
  }

  String get formattedUnitPrice => formatAmount(unitPrice);
  String get formattedTotal => formatAmount(totalAmount);

  String? get secondaryLabel {
    final parts = [
      if ((brandName ?? '').isNotEmpty) brandName!,
      if ((vendorName ?? '').isNotEmpty) vendorName!,
    ];
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  String get purchaseMetaLabel {
    final parts = [
      'Qty $quantity',
      formattedUnitPrice,
      if ((sku ?? '').isNotEmpty) 'SKU $sku',
      if ((variantName ?? '').isNotEmpty) variantName!,
      if ((color ?? '').isNotEmpty) color!,
      if ((size ?? '').isNotEmpty) 'Size $size',
    ];
    return parts.join(' · ');
  }
}

class OrderTrackingModel {
  final String currentStatus;
  final List<OrderTrackingStepModel> timeline;

  const OrderTrackingModel({
    required this.currentStatus,
    required this.timeline,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    final rawTimeline = json['timeline'] as List<dynamic>?;
    return OrderTrackingModel(
      currentStatus: (json['currentStatus'] as String?) ?? 'PENDING',
      timeline: rawTimeline == null
          ? const []
          : rawTimeline
                .map((e) => OrderTrackingStepModel.fromJson(e as Map<String, dynamic>))
                .toList(),
    );
  }
}

class OrderTrackingStepModel {
  final String status;
  final bool completed;

  const OrderTrackingStepModel({
    required this.status,
    required this.completed,
  });

  factory OrderTrackingStepModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingStepModel(
      status: (json['status'] as String?) ?? '',
      completed: (json['completed'] as bool?) ?? false,
    );
  }
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
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
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
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
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

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

List<dynamic>? _asList(dynamic value) => value is List ? value : null;

String? _firstString(List<dynamic> values) {
  for (final value in values) {
    final string = value?.toString().trim();
    if (string != null && string.isNotEmpty) return string;
  }
  return null;
}

String? _extractMediaUrl(Map<String, dynamic>? json) {
  if (json == null) return null;

  final media =
      _asList(json['media']) ??
      _asList(json['images']) ??
      _asList(json['productMedia']);
  if (media == null) return null;

  for (final item in media) {
    if (item is String && item.trim().isNotEmpty) return item.trim();

    final mediaItem = _asMap(item);
    final url = _firstString([
      mediaItem?['url'],
      mediaItem?['imageUrl'],
      mediaItem?['thumbnailUrl'],
      mediaItem?['path'],
    ]);
    if (url != null) return url;
  }

  return null;
}
