import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<PaymentEntity> deductBalance({
    required String email,
    required double amount,
    required String reference,
    required String description,
  });

  Future<PaymentEntity> addBalance({
    required String email,
    required double amount,
    required String reference,
    required String description,
  });
}
