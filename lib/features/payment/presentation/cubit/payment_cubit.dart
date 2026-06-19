import 'package:flutter_bloc/flutter_bloc.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentState.initial());

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(selectedMethod: method));
  }

  void continueToPay() {
    emit(state.copyWith(isProcessing: true));
    Future.delayed(const Duration(seconds: 2), () {
      emit(state.copyWith(isProcessing: false));
    });
  }

  Future<void> makePayment() async {
    emit(state.copyWith(status: PaymentStatus.loading, isProcessing: true));

    try {
      // TODO: Call your actual payment API here
      await Future.delayed(const Duration(seconds: 2));

      emit(state.copyWith(
        status: PaymentStatus.success,
        isProcessing: false,
        orderId: "BG-${DateTime.now().millisecondsSinceEpoch % 100000}",
        coinsEarned: 380,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentStatus.failure,
        errorMessage: 'Payment failed. Please try again.',
        isProcessing: false,
      ));
    }
  }
}