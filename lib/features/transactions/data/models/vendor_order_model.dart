class VendorOrderItemModel {
  final String id;
  final String productTitle;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalAmount;

  const VendorOrderItemModel({
    required this.id,
    required this.productTitle,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
  });

  factory VendorOrderItemModel.fromJson(Map<String, dynamic> json) => VendorOrderItemModel(
    id: json['id']?.toString() ?? '',
    productTitle: json['productTitle']?.toString() ?? '',
    sku: json['sku']?.toString() ?? '',
    quantity: _toInt(json['quantity']) ?? 0,
    unitPrice: _toDouble(json['unitPrice']) ?? 0,
    totalAmount: _toDouble(json['totalAmount']) ?? 0,
  );
}

class VendorOrderModel {
  final String id;
  final String uuid;
  final String orderStatus;
  final double totalAmount;
  final DateTime createdAt;
  final String orderNumber;
  final String paymentStatus;
  final String paymentMethod;
  final List<VendorOrderItemModel> items;

  const VendorOrderModel({
    required this.id,
    required this.uuid,
    required this.orderStatus,
    required this.totalAmount,
    required this.createdAt,
    required this.orderNumber,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.items,
  });

  factory VendorOrderModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>? ?? const {};
    final itemsJson = json['items'] as List<dynamic>? ?? const [];

    return VendorOrderModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      totalAmount: _toDouble(json['totalAmount']) ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      orderNumber: order['orderNumber']?.toString() ?? '',
      paymentStatus: order['paymentStatus']?.toString() ?? '',
      paymentMethod: order['paymentMethod']?.toString() ?? '',
      items: itemsJson
          .whereType<Map>()
          .map((e) => VendorOrderItemModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
          .toList(),
    );
  }

  static List<VendorOrderModel> listFromResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final list = data is List ? data : const [];
    return list
        .whereType<Map>()
        .map((e) => VendorOrderModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
  }
}

class VendorOrderDetailItemModel {
  final String id;
  final String productTitle;
  final String productSlug;
  final String sku;
  final String variantTitle;
  final int quantity;
  final double unitPrice;
  final double subtotalAmount;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;

  const VendorOrderDetailItemModel({
    required this.id,
    required this.productTitle,
    required this.productSlug,
    required this.sku,
    required this.variantTitle,
    required this.quantity,
    required this.unitPrice,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
  });

  factory VendorOrderDetailItemModel.fromJson(Map<String, dynamic> json) {
    final variant = json['variant'] as Map<String, dynamic>?;
    return VendorOrderDetailItemModel(
      id: json['id']?.toString() ?? '',
      productTitle: json['productTitle']?.toString() ?? '',
      productSlug: json['productSlug']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      variantTitle: variant?['title']?.toString() ?? '',
      quantity: _toInt(json['quantity']) ?? 0,
      unitPrice: _toDouble(json['unitPrice']) ?? 0,
      subtotalAmount: _toDouble(json['subtotalAmount']) ?? 0,
      discountAmount: _toDouble(json['discountAmount']) ?? 0,
      taxAmount: _toDouble(json['taxAmount']) ?? 0,
      totalAmount: _toDouble(json['totalAmount']) ?? 0,
    );
  }
}

class VendorOrderCustomerModel {
  final String fullName;
  final String phone;
  final String email;

  const VendorOrderCustomerModel({required this.fullName, required this.phone, required this.email});

  factory VendorOrderCustomerModel.fromJson(Map<String, dynamic> json) => VendorOrderCustomerModel(
    fullName: json['fullName']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
  );
}

class VendorOrderAddressModel {
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String landmark;

  const VendorOrderAddressModel({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.landmark,
  });

  factory VendorOrderAddressModel.fromJson(Map<String, dynamic> json) => VendorOrderAddressModel(
    fullName: json['fullName']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    addressLine1: json['addressLine1']?.toString() ?? '',
    addressLine2: json['addressLine2']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
    state: json['state']?.toString() ?? '',
    country: json['country']?.toString() ?? '',
    postalCode: json['postalCode']?.toString() ?? '',
    landmark: json['landmark']?.toString() ?? '',
  );

  String get formattedLines {
    final cityStatePin = [
      city,
      state,
    ].where((s) => s.isNotEmpty).join(', ');
    final countryPin = [country, postalCode].where((s) => s.isNotEmpty).join(' - ');
    return [
      addressLine1,
      if (addressLine2.isNotEmpty && addressLine2 != addressLine1) addressLine2,
      if (landmark.isNotEmpty) landmark,
      cityStatePin,
      countryPin,
    ].where((s) => s.isNotEmpty).join('\n');
  }
}

class VendorOrderDetailModel {
  final String id;
  final String uuid;
  final String orderStatus;
  final double subtotalAmount;
  final double discountAmount;
  final double taxAmount;
  final double shippingAmount;
  final double commissionAmount;
  final double totalAmount;
  final DateTime? placedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final String orderNumber;
  final String paymentStatus;
  final String paymentMethod;
  final String? notes;
  final VendorOrderCustomerModel? customer;
  final VendorOrderAddressModel? address;
  final List<VendorOrderDetailItemModel> items;

  const VendorOrderDetailModel({
    required this.id,
    required this.uuid,
    required this.orderStatus,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.shippingAmount,
    required this.commissionAmount,
    required this.totalAmount,
    required this.placedAt,
    required this.shippedAt,
    required this.deliveredAt,
    required this.cancelledAt,
    required this.createdAt,
    required this.orderNumber,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.notes,
    required this.customer,
    required this.address,
    required this.items,
  });

  factory VendorOrderDetailModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>? ?? const {};
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    final userJson = order['user'] as Map<String, dynamic>?;
    final addressJson = order['address'] as Map<String, dynamic>?;

    return VendorOrderDetailModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      subtotalAmount: _toDouble(json['subtotalAmount']) ?? 0,
      discountAmount: _toDouble(json['discountAmount']) ?? 0,
      taxAmount: _toDouble(json['taxAmount']) ?? 0,
      shippingAmount: _toDouble(json['shippingAmount']) ?? 0,
      commissionAmount: _toDouble(json['commissionAmount']) ?? 0,
      totalAmount: _toDouble(json['totalAmount']) ?? 0,
      placedAt: DateTime.tryParse(json['placedAt']?.toString() ?? ''),
      shippedAt: DateTime.tryParse(json['shippedAt']?.toString() ?? ''),
      deliveredAt: DateTime.tryParse(json['deliveredAt']?.toString() ?? ''),
      cancelledAt: DateTime.tryParse(json['cancelledAt']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      orderNumber: order['orderNumber']?.toString() ?? '',
      paymentStatus: order['paymentStatus']?.toString() ?? '',
      paymentMethod: order['paymentMethod']?.toString() ?? '',
      notes: order['notes']?.toString(),
      customer: userJson == null ? null : VendorOrderCustomerModel.fromJson(userJson),
      address: addressJson == null ? null : VendorOrderAddressModel.fromJson(addressJson),
      items: itemsJson
          .whereType<Map>()
          .map((e) => VendorOrderDetailItemModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
          .toList(),
    );
  }

  /// Returns null when the endpoint's success envelope carries `data: null`
  /// (order not found — the API returns 200 with a null payload, not a 404).
  static VendorOrderDetailModel? fromResponse(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) return null;
    return VendorOrderDetailModel.fromJson(data);
  }
}

double? _toDouble(dynamic value) {
  if (value == null || value == '') return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _toInt(dynamic value) {
  if (value == null || value == '') return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
