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

class Order {
  final String orderId;
  final String customerName;
  final String itemSummary;
  final String timeAgo;
  final int daysAgo;
  final PaymentType payment;
  final OrderStatus status;

  const Order({
    required this.orderId,
    required this.customerName,
    required this.itemSummary,
    required this.timeAgo,
    required this.daysAgo,
    required this.payment,
    required this.status,
  });
}

class OrderMockData {
  static const List<Order> orders = [
    Order(
      orderId: 'ORD12390',
      customerName: 'Rashi Khurana',
      itemSummary: 'Cotton T-Shirt +2 more',
      timeAgo: '12 min ago',
      daysAgo: 0,
      payment: PaymentType.cod,
      status: OrderStatus.pending,
    ),
    Order(
      orderId: 'ORD12389',
      customerName: 'Gargi Rana',
      itemSummary: 'Gold Ring',
      timeAgo: '38 min ago',
      daysAgo: 0,
      payment: PaymentType.paid,
      status: OrderStatus.confirmed,
    ),
    Order(
      orderId: 'ORD12387',
      customerName: 'Shubham Chitransh',
      itemSummary: 'Running Shoes +1 more',
      timeAgo: '1 hr ago',
      daysAgo: 0,
      payment: PaymentType.paid,
      status: OrderStatus.processing,
    ),
    Order(
      orderId: 'ORD12386',
      customerName: 'Achal Sharma',
      itemSummary: 'Leather Wallet',
      timeAgo: '2 hrs ago',
      daysAgo: 0,
      payment: PaymentType.paid,
      status: OrderStatus.delivered,
    ),
    Order(
      orderId: 'ORD12381',
      customerName: 'Priya Nair',
      itemSummary: 'Wireless Earbuds',
      timeAgo: '5 hrs ago',
      daysAgo: 0,
      payment: PaymentType.paid,
      status: OrderStatus.shipped,
    ),
    Order(
      orderId: 'ORD12350',
      customerName: 'Karan Mehta',
      itemSummary: 'Denim Jacket',
      timeAgo: '3 days ago',
      daysAgo: 3,
      payment: PaymentType.cod,
      status: OrderStatus.delivered,
    ),
    Order(
      orderId: 'ORD12298',
      customerName: 'Ishita Verma',
      itemSummary: 'Silver Bracelet +1 more',
      timeAgo: '12 days ago',
      daysAgo: 12,
      payment: PaymentType.paid,
      status: OrderStatus.delivered,
    ),
  ];

  static List<Order> filtered({required OrderStatus? status, required DateRangeFilter dateRange}) {
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
}
