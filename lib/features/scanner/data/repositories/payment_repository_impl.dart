import 'package:injectable/injectable.dart';

import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';

import '../datasource/payment_remote_datasource.dart';
import '../models/payment_request_model.dart';

@Injectable(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remote;

  const PaymentRepositoryImpl(this._remote);

  @override
  Future<PaymentEntity> deductBalance({
    required String email,
    required double amount,
    required String reference,
    required String description,
  }) async {
    final response = await _remote.processPayment(
      PaymentRequestModel(
        email: email,
        amount: amount,
        operation: 'deduct',
        reference: reference,
        description: description,
      ),
    );

    return PaymentEntity(
      transactionId: response.transactionId,
      email: response.email,
      operation: response.operation,
      amount: response.amount,
      reference: response.referenceNumber,
      status: response.status,
    );
  }

  @override
  Future<PaymentEntity> addBalance({
    required String email,
    required double amount,
    required String reference,
    required String description,
  }) async {
    final response = await _remote.processPayment(
      PaymentRequestModel(
        email: email,
        amount: amount,
        operation: 'add',
        reference: reference,
        description: description,
      ),
    );

    return PaymentEntity(
      transactionId: response.transactionId,
      email: response.email,
      operation: response.operation,
      amount: response.amount,
      status: response.status,
      reference: response.referenceNumber,
    );
  }
}
