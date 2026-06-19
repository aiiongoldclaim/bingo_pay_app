enum OrderStatus { pending, confirmed, delivered }

class RecentOrder {
  final String orderId;
  final String customerName;
  final String timeAgo;
  final OrderStatus status;

  const RecentOrder({
    required this.orderId,
    required this.customerName,
    required this.timeAgo,
    required this.status,
  });
}

class SalesPoint {
  final String dayLabel;
  final double revenue;

  const SalesPoint({required this.dayLabel, required this.revenue});
}

class DashboardMockData {
  static const String vendorName = 'Nishant';
  static const String shopName = 'Aiion Gold Store';

  static const double todaysRevenue = 48250;
  static const double revenueChangePercent = 12;

  static const int pendingOrders = 12;
  static const int lowStockCount = 7;

  static const List<SalesPoint> salesTrend = [
    SalesPoint(dayLabel: 'Mon', revenue: 32000),
    SalesPoint(dayLabel: 'Tue', revenue: 41000),
    SalesPoint(dayLabel: 'Wed', revenue: 38500),
    SalesPoint(dayLabel: 'Thu', revenue: 52000),
    SalesPoint(dayLabel: 'Fri', revenue: 45500),
    SalesPoint(dayLabel: 'Sat', revenue: 60500),
    SalesPoint(dayLabel: 'Sun', revenue: 48250),
  ];

  static const List<RecentOrder> recentOrders = [
    RecentOrder(
      orderId: 'ORD12390',
      customerName: 'Rashi Khurana',
      timeAgo: '12 min ago',
      status: OrderStatus.pending,
    ),
    RecentOrder(
      orderId: 'ORD12389',
      customerName: 'Gargi Rana',
      timeAgo: '38 min ago',
      status: OrderStatus.confirmed,
    ),
    RecentOrder(
      orderId: 'ORD12386',
      customerName: 'Achal Sharma',
      timeAgo: '2 hrs ago',
      status: OrderStatus.delivered,
    ),
  ];
}
