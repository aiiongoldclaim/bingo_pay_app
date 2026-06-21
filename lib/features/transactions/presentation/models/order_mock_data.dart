enum OrderStatus { pending, confirmed, processing, shipped, delivered }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.confirmed => 'Confirmed',
    OrderStatus.processing => 'Processing',
    OrderStatus.shipped => 'Shipped',
    OrderStatus.delivered => 'Delivered',
  };
}

enum PaymentType { cod, paid }

enum DateRangeFilter { today, thisWeek, thisMonth, custom }

extension DateRangeFilterLabel on DateRangeFilter {
  String get label => switch (this) {
    DateRangeFilter.today => 'Today',
    DateRangeFilter.thisWeek => 'This week',
    DateRangeFilter.thisMonth => 'This month',
    DateRangeFilter.custom => 'Custom',
  };
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  const OrderItem({required this.productName, required this.quantity, required this.price});

  factory OrderItem.fromApi(Map<String, dynamic> json) => OrderItem(
    productName: json['product_name']?.toString() ?? '',
    quantity: _toInt(json['quantity']) ?? 0,
    price: _toDouble(json['price']) ?? 0,
  );

  Map<String, dynamic> toApi() => {
    'product_name': productName,
    'quantity': quantity,
    'price': price,
  };
}

class Order {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double totalAmount;
  final PaymentType payment;
  final OrderStatus status;
  final DateTime createdAt;

  const Order({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.payment,
    required this.status,
    required this.createdAt,
  });

  String get itemSummary {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first.productName;
    return '${items.first.productName} +${items.length - 1} more';
  }

  String get timeAgo => _formatTimeAgo(createdAt);

  int get daysAgo => DateTime.now().difference(createdAt).inDays;

  factory Order.fromApi(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final items = itemsJson is List
        ? itemsJson
              .whereType<Map>()
              .map((e) => OrderItem.fromApi(e.map((k, v) => MapEntry(k.toString(), v))))
              .toList()
        : <OrderItem>[];

    return Order(
      orderId: json['order_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      items: items,
      totalAmount: _toDouble(json['total_amount']) ?? 0,
      payment: json['payment_type']?.toString() == 'paid' ? PaymentType.paid : PaymentType.cod,
      status: _statusFromApi(json['status']?.toString()),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

OrderStatus _statusFromApi(String? value) {
  return OrderStatus.values.firstWhere((s) => s.name == value, orElse: () => OrderStatus.pending);
}

List<Order> filterOrders(
  List<Order> orders, {
  required OrderStatus? status,
  required DateRangeFilter dateRange,
}) {
  return orders.where((order) {
    final matchesStatus = status == null || order.status == status;
    final matchesDate = switch (dateRange) {
      DateRangeFilter.today => order.daysAgo == 0,
      DateRangeFilter.thisWeek => order.daysAgo <= 7,
      DateRangeFilter.thisMonth => order.daysAgo <= 30,
      DateRangeFilter.custom => true,
    };
    return matchesStatus && matchesDate;
  }).toList();
}

String _formatTimeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
  return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
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
