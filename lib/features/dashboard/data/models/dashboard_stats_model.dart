class DashboardStatsModel {
  final int totalProducts;
  final int approvedProducts;
  final int draftProducts;
  final int rejectedProducts;
  final int totalVariants;
  final int totalOrders;
  final int pendingOrders;
  final int deliveredOrders;

  const DashboardStatsModel({
    required this.totalProducts,
    required this.approvedProducts,
    required this.draftProducts,
    required this.rejectedProducts,
    required this.totalVariants,
    required this.totalOrders,
    required this.pendingOrders,
    required this.deliveredOrders,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalProducts: json['totalProducts'] as int? ?? 0,
      approvedProducts: json['approvedProducts'] as int? ?? 0,
      draftProducts: json['draftProducts'] as int? ?? 0,
      rejectedProducts: json['rejectedProducts'] as int? ?? 0,
      totalVariants: json['totalVariants'] as int? ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      pendingOrders: json['pendingOrders'] as int? ?? 0,
      deliveredOrders: json['deliveredOrders'] as int? ?? 0,
    );
  }
}
