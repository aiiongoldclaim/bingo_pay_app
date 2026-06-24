import 'package:injectable/injectable.dart';

import '../entities/payment_entity.dart';
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
    await _repository.deductBalance(
      email: customerEmail,
      amount: amount,
      reference: reference,
      description: 'Marketplace purchase settlement',
    );

    await _repository.addBalance(
      email: merchantEmail,
      amount: amount,
      reference: reference,
      description: 'Marketplace purchase settlement',
    );
  }
}
