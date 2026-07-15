/// Typed view of `/api/v1/vendor/analytics`. All parsing is defensive —
/// missing keys fall back to zero/empty so a partial payload never throws.
class VendorAnalytics {
  final AnalyticsSummary summary;
  final AnalyticsOrders orders;
  final AnalyticsRevenue revenue;
  final AnalyticsInventory inventory;
  final AnalyticsCatalog catalog;
  final List<TimeseriesPoint> timeseries;
  final List<TopProduct> topProducts;
  final List<AnalyticsRecentOrder> recentOrders;

  const VendorAnalytics({
    required this.summary,
    required this.orders,
    required this.revenue,
    required this.inventory,
    required this.catalog,
    required this.timeseries,
    required this.topProducts,
    required this.recentOrders,
  });

  factory VendorAnalytics.fromJson(Map<String, dynamic> json) {
    return VendorAnalytics(
      summary: AnalyticsSummary.fromJson(_map(json['summary'])),
      orders: AnalyticsOrders.fromJson(_map(json['orders'])),
      revenue: AnalyticsRevenue.fromJson(_map(json['revenue'])),
      inventory: AnalyticsInventory.fromJson(_map(json['inventory'])),
      catalog: AnalyticsCatalog.fromJson(_map(json['catalog'])),
      timeseries: _list(json['timeseries'])
          .map(TimeseriesPoint.fromJson)
          .toList(),
      topProducts: _list(json['topProducts']).map(TopProduct.fromJson).toList(),
      recentOrders: _list(json['recentOrders'])
          .map(AnalyticsRecentOrder.fromJson)
          .toList(),
    );
  }
}

class AnalyticsSummary {
  final int newOrders;
  final double ordersGrowthPct;
  final double grossSales;
  final double commission;
  final double netEarnings;
  final double revenueGrowthPct;
  final double averageOrderValue;
  final int totalOrdersAllTime;

  const AnalyticsSummary({
    required this.newOrders,
    required this.ordersGrowthPct,
    required this.grossSales,
    required this.commission,
    required this.netEarnings,
    required this.revenueGrowthPct,
    required this.averageOrderValue,
    required this.totalOrdersAllTime,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      newOrders: _int(json['newOrders']),
      ordersGrowthPct: _double(json['ordersGrowthPct']),
      grossSales: _double(json['grossSales']),
      commission: _double(json['commission']),
      netEarnings: _double(json['netEarnings']),
      revenueGrowthPct: _double(json['revenueGrowthPct']),
      averageOrderValue: _double(json['averageOrderValue']),
      totalOrdersAllTime: _int(json['totalOrdersAllTime']),
    );
  }
}

class AnalyticsOrders {
  final int newOrders;
  final int previousPeriodOrders;
  final double growthPct;
  final int totalOrdersAllTime;
  final Map<String, int> byStatus;

  const AnalyticsOrders({
    required this.newOrders,
    required this.previousPeriodOrders,
    required this.growthPct,
    required this.totalOrdersAllTime,
    required this.byStatus,
  });

  factory AnalyticsOrders.fromJson(Map<String, dynamic> json) {
    return AnalyticsOrders(
      newOrders: _int(json['newOrders']),
      previousPeriodOrders: _int(json['previousPeriodOrders']),
      growthPct: _double(json['growthPct']),
      totalOrdersAllTime: _int(json['totalOrdersAllTime']),
      byStatus: _map(json['byStatus'])
          .map((key, value) => MapEntry(key, _int(value))),
    );
  }
}

class AnalyticsRevenue {
  final double grossSales;
  final double commission;
  final double netEarnings;
  final double averageOrderValue;
  final double subtotal;
  final double discount;
  final double tax;
  final double shipping;
  final List<PayoutSummary> payouts;

  const AnalyticsRevenue({
    required this.grossSales,
    required this.commission,
    required this.netEarnings,
    required this.averageOrderValue,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.shipping,
    required this.payouts,
  });

  factory AnalyticsRevenue.fromJson(Map<String, dynamic> json) {
    final breakdown = _map(json['breakdown']);
    return AnalyticsRevenue(
      grossSales: _double(json['grossSales']),
      commission: _double(json['commission']),
      netEarnings: _double(json['netEarnings']),
      averageOrderValue: _double(json['averageOrderValue']),
      subtotal: _double(breakdown['subtotal']),
      discount: _double(breakdown['discount']),
      tax: _double(breakdown['tax']),
      shipping: _double(breakdown['shipping']),
      payouts: _list(json['payouts']).map(PayoutSummary.fromJson).toList(),
    );
  }
}

class PayoutSummary {
  final String status;
  final int count;
  final double netAmount;

  const PayoutSummary({
    required this.status,
    required this.count,
    required this.netAmount,
  });

  factory PayoutSummary.fromJson(Map<String, dynamic> json) {
    return PayoutSummary(
      status: json['status'] as String? ?? '',
      count: _int(json['count']),
      netAmount: _double(json['netAmount']),
    );
  }
}

class AnalyticsInventory {
  final int totalVariants;
  final int stockOnHand;
  final int reservedStock;
  final int soldStock;
  final int returnedStock;
  final int damagedStock;
  final int inStockVariants;
  final int lowStockVariants;
  final int outOfStockVariants;

  const AnalyticsInventory({
    required this.totalVariants,
    required this.stockOnHand,
    required this.reservedStock,
    required this.soldStock,
    required this.returnedStock,
    required this.damagedStock,
    required this.inStockVariants,
    required this.lowStockVariants,
    required this.outOfStockVariants,
  });

  factory AnalyticsInventory.fromJson(Map<String, dynamic> json) {
    return AnalyticsInventory(
      totalVariants: _int(json['totalVariants']),
      stockOnHand: _int(json['stockOnHand']),
      reservedStock: _int(json['reservedStock']),
      soldStock: _int(json['soldStock']),
      returnedStock: _int(json['returnedStock']),
      damagedStock: _int(json['damagedStock']),
      inStockVariants: _int(json['inStockVariants']),
      lowStockVariants: _int(json['lowStockVariants']),
      outOfStockVariants: _int(json['outOfStockVariants']),
    );
  }
}

class AnalyticsCatalog {
  final int totalProducts;
  final int publishedProducts;
  final int featuredProducts;
  final Map<String, int> byStatus;

  const AnalyticsCatalog({
    required this.totalProducts,
    required this.publishedProducts,
    required this.featuredProducts,
    required this.byStatus,
  });

  factory AnalyticsCatalog.fromJson(Map<String, dynamic> json) {
    return AnalyticsCatalog(
      totalProducts: _int(json['totalProducts']),
      publishedProducts: _int(json['publishedProducts']),
      featuredProducts: _int(json['featuredProducts']),
      byStatus: _map(json['byStatus'])
          .map((key, value) => MapEntry(key, _int(value))),
    );
  }
}

class TimeseriesPoint {
  final DateTime date;
  final int orders;
  final double revenue;

  const TimeseriesPoint({
    required this.date,
    required this.orders,
    required this.revenue,
  });

  factory TimeseriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeseriesPoint(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      orders: _int(json['orders']),
      revenue: _double(json['revenue']),
    );
  }
}

class TopProduct {
  final String uuid;
  final String title;
  final int unitsSold;
  final int orderLines;
  final double revenue;

  const TopProduct({
    required this.uuid,
    required this.title,
    required this.unitsSold,
    required this.orderLines,
    required this.revenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      unitsSold: _int(json['unitsSold']),
      orderLines: _int(json['orderLines']),
      revenue: _double(json['revenue']),
    );
  }
}

class AnalyticsRecentOrder {
  final String uuid;
  final String orderNumber;
  final String status;
  final double amount;
  final DateTime? createdAt;

  const AnalyticsRecentOrder({
    required this.uuid,
    required this.orderNumber,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  factory AnalyticsRecentOrder.fromJson(Map<String, dynamic> json) {
    return AnalyticsRecentOrder(
      uuid: json['uuid'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      status: json['status'] as String? ?? '',
      amount: _double(json['amount']),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : const {};

List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList()
    : const [];

int _int(Object? value) => value is num ? value.toInt() : 0;

double _double(Object? value) => value is num ? value.toDouble() : 0;
