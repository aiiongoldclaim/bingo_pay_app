class OrderModel {
  final String orderId;
  final DateTime orderDate;
  final String status; // "Delivered", "In Transit", "Cancelled", "Pending"
  final double totalAmount;
  final int itemCount;
  final String mainItemName;
  final String? imageUrl;
  final String deliveryDate;

  OrderModel({
    required this.orderId,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.itemCount,
    required this.mainItemName,
    this.imageUrl,
    required this.deliveryDate,
  });

  String get formattedDate => "${orderDate.day} ${monthName(orderDate.month)} ${orderDate.year}";

  String get statusDisplay => status;

  String monthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}