import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/process_payment_usecase.dart';
import 'payment_state.dart';

@injectable
class PaymentCubit extends Cubit<PaymentState> {
  final ProcessPaymentUseCase _processPayment;

  PaymentCubit(this._processPayment) : super(PaymentInitial());

  Future<void> pay({
    required String customerEmail,
    required String merchantEmail,
    required double amount,
    required String reference,
  }) async {
    print("============ PAYMENT CUBIT ============");

    print(customerEmail);
    print(merchantEmail);
    print(amount);
    print(reference);

    try {
      emit(PaymentLoading());

      await _processPayment(
        customerEmail: customerEmail,
        merchantEmail: merchantEmail,
        amount: amount,
        reference: reference,
      );

      print("Payment Success");

      emit(PaymentSuccess());
    } catch (e) {
      print(e);

      emit(PaymentFailure(e.toString()));
    }
  }
}
