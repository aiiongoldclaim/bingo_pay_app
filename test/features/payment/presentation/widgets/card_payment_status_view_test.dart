import 'package:bingo_pay/features/payment/data/models/stripe_status_response.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/card_payment_state.dart';
import 'package:bingo_pay/features/payment/presentation/widgets/card_payment_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tapped = <String>[];

  Future<void> pumpView(
    WidgetTester tester, {
    required bool isCrypto,
    String? gatewayStatus,
  }) {
    tapped.clear();
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardPaymentStatusView(
            state: CardPaymentState(
              phase: CardPaymentPhase.confirming,
              paymentUuid: 'p-1',
              checkoutUrl: 'https://nowpayments.io/payment/?iid=1',
              isCrypto: isCrypto,
              payment: StripeStatusResponse(
                status: StripePaymentStatus.pending,
                refunded: false,
                amount: 118,
                currency: 'USD',
                gatewayStatus: gatewayStatus,
              ),
            ),
            onCheckAgain: () => tapped.add('check'),
            onResumeCheckout: () => tapped.add('resume'),
            onBackToCheckout: () => tapped.add('back'),
            onGoHome: () => tapped.add('home'),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'an unpaid crypto invoice offers its page again, or another way to pay',
    (tester) async {
      await pumpView(tester, isCrypto: true, gatewayStatus: 'waiting');

      expect(find.text('Waiting for your payment'), findsOneWidget);

      await tester.tap(find.text('Back to payment page'));
      await tester.tap(find.text('Pay another way'));
      expect(tapped, ['resume', 'back']);
    },
  );

  testWidgets(
    'once the coins are on the network there is nothing left to choose',
    (tester) async {
      await pumpView(tester, isCrypto: true, gatewayStatus: 'confirming');

      expect(find.text('Confirming your payment'), findsOneWidget);
      expect(
        find.text('Your payment is on the network and is being confirmed.'),
        findsOneWidget,
      );
      expect(find.text('Back to payment page'), findsNothing);
      expect(find.text('Pay another way'), findsNothing);
    },
  );

  testWidgets(
    'a part payment asks the customer not to send more',
    (tester) async {
      await pumpView(tester, isCrypto: true, gatewayStatus: 'partially_paid');

      expect(find.textContaining('do not send another payment'), findsOneWidget);
      expect(find.text('Pay another way'), findsNothing);
    },
  );

  testWidgets(
    'a card payment being confirmed is never offered the crypto choices',
    (tester) async {
      // Stripe reports a gateway status too; it means nothing on this rail.
      await pumpView(tester, isCrypto: false, gatewayStatus: 'open');

      expect(find.text('Confirming your payment'), findsOneWidget);
      expect(find.text('Back to payment page'), findsNothing);
      expect(find.text('Pay another way'), findsNothing);
    },
  );
}
