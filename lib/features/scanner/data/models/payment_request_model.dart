class PaymentRequestModel {
  final String email;
  final double amount;
  final String operation;
  final String reference;
  final String description;

  const PaymentRequestModel({
    required this.email,
    required this.amount,
    required this.operation,
    required this.reference,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "amount": amount,
      "operation": operation,
      "reference": reference,
      "description": description,
    };
  }
}
