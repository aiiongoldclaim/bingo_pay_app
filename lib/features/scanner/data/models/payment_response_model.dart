class PaymentResponseModel {
  final String transactionId;
  final String email;
  final String operation;
  final double amount;
  final String referenceNumber;
  final String status;

  const PaymentResponseModel({
    required this.transactionId,
    required this.email,
    required this.operation,
    required this.amount,
    required this.referenceNumber,
    required this.status,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    final result = json['data']['result']['data'];

    return PaymentResponseModel(
      transactionId: result['transactionId'] ?? '',
      email: result['email'] ?? '',
      operation: result['operation'] ?? '',
      amount: (result['amount'] as num).toDouble(),
      referenceNumber: result['referenceNumber'] ?? '',
      status: result['status'] ?? '',
    );
  }
}
