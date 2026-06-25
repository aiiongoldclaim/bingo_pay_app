import 'package:injectable/injectable.dart';

import '../repositories/payment_repository.dart';

@injectable
class ProcessPaymentUseCase {
  final PaymentRepository _repository;

  const ProcessPaymentUseCase(this._repository);

  Future<void> call({
    required String customerEmail,
    required String merchantEmail,
    required double amount,
    required String reference,
  }) async {
    print("============= PROCESS PAYMENT =============");
    print("Customer Email : $customerEmail");
    print("Merchant Email : $merchantEmail");
    print("Amount         : $amount");

    final deductReference = "${reference}_D";
    final addReference = "${reference}_A";

    print("Deduct Reference : $deductReference");
    print("Add Reference    : $addReference");

    print("============= DEDUCT API =============");

    await _repository.deductBalance(
      email: customerEmail,
      amount: amount,
      reference: deductReference,
      description: 'Marketplace purchase settlement',
    );

    print("Deduct API Success");

    print("============= ADD API =============");

    await _repository.addBalance(
      email: merchantEmail,
      amount: amount,
      reference: addReference,
      description: 'Marketplace purchase settlement',
    );

    print("Add API Success");

    print("============= PAYMENT COMPLETED =============");
  }
}
