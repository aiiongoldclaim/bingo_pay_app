class PaymentEntity {
  final String transactionId;
  final String email;
  final String operation;
  final double amount;
  final String reference;
  final String status;

  const PaymentEntity({
    required this.transactionId,
    required this.email,
    required this.operation,
    required this.amount,
    required this.reference,
    required this.status,
  });
}
