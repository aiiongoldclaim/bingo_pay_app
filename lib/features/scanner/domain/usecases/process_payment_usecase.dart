import 'package:injectable/injectable.dart';

import '../../../../core/utils/logger.dart';
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
    AppLogger.log("============= PROCESS PAYMENT =============");
    AppLogger.log("Customer Email : $customerEmail");
    AppLogger.log("Merchant Email : $merchantEmail");
    AppLogger.log("Amount         : $amount");

    final deductReference = "${reference}_D";
    final addReference = "${reference}_A";

    AppLogger.log("Deduct Reference : $deductReference");
    AppLogger.log("Add Reference    : $addReference");

    AppLogger.log("============= DEDUCT API =============");

    await _repository.deductBalance(
      email: customerEmail,
      amount: amount,
      reference: deductReference,
      description: 'Marketplace purchase settlement',
    );

    AppLogger.log("Deduct API Success");

    AppLogger.log("============= ADD API =============");

    await _repository.addBalance(
      email: merchantEmail,
      amount: amount,
      reference: addReference,
      description: 'Marketplace purchase settlement',
    );

    AppLogger.log("Add API Success");

    AppLogger.log("============= PAYMENT COMPLETED =============");
  }
}
