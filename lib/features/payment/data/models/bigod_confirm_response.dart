class BigodOrderRef {
  final String uuid;
  final String orderNumber;

  const BigodOrderRef({required this.uuid, required this.orderNumber});

  factory BigodOrderRef.fromJson(Map<String, dynamic> json) {
    return BigodOrderRef(
      uuid: json['uuid'] as String,
      orderNumber: json['orderNumber'] as String,
    );
  }
}

class BigodConfirmResponse {
  final String status;
  final double amount;
  final BigodOrderRef order;
  final double balance;

  const BigodConfirmResponse({
    required this.status,
    required this.amount,
    required this.order,
    required this.balance,
  });

  // API shape: { success, statusCode, message, data: { message, data: {
  //   status, amount, order: { uuid, orderNumber }, balance, ... } }, timestamp }
  factory BigodConfirmResponse.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>? ?? const {};
    final inner = outer['data'] as Map<String, dynamic>? ?? outer;
    return BigodConfirmResponse(
      status: inner['status'] as String,
      amount: (inner['amount'] as num).toDouble(),
      order: BigodOrderRef.fromJson(inner['order'] as Map<String, dynamic>),
      balance: (inner['balance'] as num).toDouble(),
    );
  }
}
