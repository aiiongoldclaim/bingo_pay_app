import 'dart:async';

import 'package:bingo_pay/features/payment/data/models/stripe_intent_response.dart';
import 'package:bingo_pay/features/payment/data/models/stripe_status_response.dart';
import 'package:bingo_pay/features/payment/data/stripe_payment_datasource.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/card_payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// Follows one card checkout from Stripe's page to its outcome.
//
// The app never marks a payment paid: Stripe's webhook tells the server, the
// server places the order, and this cubit polls /status until it says so.
class CardPaymentCubit extends Cubit<CardPaymentState> {
  CardPaymentCubit({
    required StripeIntentResponse intent,
    StripePaymentDataSource? stripePaymentDataSource,
  }) : _stripePaymentDataSource =
           stripePaymentDataSource ?? GetIt.I<StripePaymentDataSource>(),
       super(
         CardPaymentState(
           paymentUuid: intent.paymentUuid,
           checkoutUrl: intent.checkoutUrl,
         ),
       );

  // Every 3s for the first ten checks, then every 10s: about ten minutes of
  // checking before the screen stops asking on its own.
  static const _fastPolls = 10;
  static const _maxPolls = 67;

  final StripePaymentDataSource _stripePaymentDataSource;

  Timer? _timer;
  int _pollsLeft = 0;
  // Bumped whenever polling restarts or stops, so a loop still waiting on its
  // request knows not to carry on.
  int _pollRun = 0;

  // Stripe sent the customer to its success page. That is only a hint — the
  // server decides whether the card was charged.
  void onPaymentSubmitted() {
    emit(
      state.copyWith(
        phase: CardPaymentPhase.confirming,
        gaveUp: false,
        clearError: true,
      ),
    );
    _startPolling();
  }

  // The customer pressed back on Stripe's page, or closed it: close the
  // checkout on the server, which frees held stock and booking slots. If the
  // card had in fact been charged, the server settles the order instead and
  // answers PAID.
  Future<void> onCheckoutLeft() async {
    _stopPolling();
    // A fresh state, so `payment` stays null if this call fails: without an
    // answer nobody knows whether the card was charged.
    emit(
      CardPaymentState(
        phase: CardPaymentPhase.backedOut,
        paymentUuid: state.paymentUuid,
        checkoutUrl: state.checkoutUrl,
        isChecking: true,
      ),
    );

    try {
      final payment = await _stripePaymentDataSource.cancel(state.paymentUuid);
      if (isClosed) return;
      _apply(payment);
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isChecking: false));
    }
  }

  void checkAgain() {
    emit(state.copyWith(gaveUp: false, clearError: true));
    _startPolling();
  }

  void _apply(StripeStatusResponse payment) {
    final wasConfirming = state.phase == CardPaymentPhase.confirming;

    final phase = switch (payment.status) {
      StripePaymentStatus.paid => CardPaymentPhase.paid,
      StripePaymentStatus.reconciling => CardPaymentPhase.reconciling,
      StripePaymentStatus.failed ||
      StripePaymentStatus.expired ||
      StripePaymentStatus.cancelled => CardPaymentPhase.closed,
      // Charged with the order being placed, or still open because the server
      // would not cancel a payment that is clearing: keep watching either way.
      StripePaymentStatus.processing ||
      StripePaymentStatus.pending => CardPaymentPhase.confirming,
    };

    emit(
      state.copyWith(
        phase: phase,
        payment: payment,
        isChecking: false,
        clearError: true,
      ),
    );

    if (phase == CardPaymentPhase.confirming && !wasConfirming) {
      _startPolling();
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _pollsLeft = _maxPolls;
    _poll(++_pollRun);
  }

  void _stopPolling() {
    _pollRun++;
    _timer?.cancel();
  }

  Future<void> _poll(int run) async {
    if (isClosed || run != _pollRun) return;

    try {
      final payment = await _stripePaymentDataSource.getStatus(
        state.paymentUuid,
      );
      if (isClosed || run != _pollRun) return;
      _apply(payment);
    } catch (_) {
      if (isClosed || run != _pollRun) return;
      emit(
        state.copyWith(
          errorMessage: 'We could not check your payment just now.',
        ),
      );
    }

    if (state.phase != CardPaymentPhase.confirming) return;

    if (--_pollsLeft <= 0) {
      emit(state.copyWith(gaveUp: true));
      return;
    }

    final fast = _pollsLeft > _maxPolls - _fastPolls;
    _timer = Timer(Duration(seconds: fast ? 3 : 10), () => _poll(run));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
