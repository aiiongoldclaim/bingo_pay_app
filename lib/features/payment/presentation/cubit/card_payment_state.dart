import '../../data/models/stripe_status_response.dart';

enum CardPaymentPhase {
  // Stripe's checkout page is on screen.
  checkout,
  // Back from Stripe; waiting for the server to report the outcome.
  confirming,
  // Left Stripe's page without paying: the checkout is being closed, or the
  // server could not be reached to close it.
  backedOut,
  paid,
  // Failed, expired or cancelled — nothing more will happen to it.
  closed,
  // Paid, but under manual review before the order is confirmed.
  reconciling,
}

class CardPaymentState {
  final CardPaymentPhase phase;
  final String paymentUuid;
  final String checkoutUrl;

  // Latest answer from GET /payments/stripe/status, once there is one.
  final StripeStatusResponse? payment;

  final bool isChecking;
  // Polling stopped after its time limit; the server is still watching.
  final bool gaveUp;
  final String? errorMessage;

  const CardPaymentState({
    this.phase = CardPaymentPhase.checkout,
    required this.paymentUuid,
    required this.checkoutUrl,
    this.payment,
    this.isChecking = false,
    this.gaveUp = false,
    this.errorMessage,
  });

  CardPaymentState copyWith({
    CardPaymentPhase? phase,
    StripeStatusResponse? payment,
    bool? isChecking,
    bool? gaveUp,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CardPaymentState(
      phase: phase ?? this.phase,
      paymentUuid: paymentUuid,
      checkoutUrl: checkoutUrl,
      payment: payment ?? this.payment,
      isChecking: isChecking ?? this.isChecking,
      gaveUp: gaveUp ?? this.gaveUp,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isRefunded => payment?.refunded ?? false;
}
