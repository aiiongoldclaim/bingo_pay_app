class BigodIntentBreakdown {
  final double subtotal;
  final double discount;
  final double tax;
  final double shipping;
  final double total;

  const BigodIntentBreakdown({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.shipping,
    required this.total,
  });

  factory BigodIntentBreakdown.fromJson(Map<String, dynamic> json) {
    return BigodIntentBreakdown(
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

class BigodIntentResponse {
  final String token;
  final double amount;
  final BigodIntentBreakdown breakdown;
  final double? customerBalance;

  const BigodIntentResponse({
    required this.token,
    required this.amount,
    required this.breakdown,
    required this.customerBalance,
  });

  // API shape: { success, statusCode, message, data: { message, data: {
  //   token, amount, breakdown: {...}, customerBalance, ... } }, timestamp }
  factory BigodIntentResponse.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>? ?? const {};
    final inner = outer['data'] as Map<String, dynamic>? ?? outer;
    return BigodIntentResponse(
      token: inner['token'] as String,
      amount: (inner['amount'] as num).toDouble(),
      breakdown: BigodIntentBreakdown.fromJson(
        inner['breakdown'] as Map<String, dynamic>,
      ),
      customerBalance: (inner['customerBalance'] as num?)?.toDouble(),
    );
  }
}
