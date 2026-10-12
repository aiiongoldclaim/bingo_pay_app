import 'package:bingo_pay/features/payment/data/models/stripe_intent_response.dart';
import 'package:bingo_pay/features/payment/data/models/stripe_status_response.dart';
import 'package:bingo_pay/features/payment/data/stripe_payment_datasource.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/card_payment_cubit.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/card_payment_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStripePaymentDataSource extends Mock
    implements StripePaymentDataSource {}

const _checkoutUrl = 'https://checkout.stripe.com/c/pay/cs_test_123';

const _intent = StripeIntentResponse(
  paymentUuid: 'p-1',
  checkoutUrl: _checkoutUrl,
  amount: 118,
);

const _order = StripeOrderRef(uuid: 'o-uuid', orderNumber: 'ORD-1');

StripeStatusResponse _status(
  StripePaymentStatus status, {
  bool refunded = false,
  StripeOrderRef? order,
}) {
  return StripeStatusResponse(
    status: status,
    refunded: refunded,
    amount: 118,
    currency: 'USD',
    order: order,
  );
}

void main() {
  late MockStripePaymentDataSource mockStripe;

  setUp(() {
    mockStripe = MockStripePaymentDataSource();
  });

  CardPaymentCubit buildCubit() {
    return CardPaymentCubit(
      intent: _intent,
      stripePaymentDataSource: mockStripe,
    );
  }

  test('starts on Stripe\'s checkout page', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.phase, CardPaymentPhase.checkout);
    expect(cubit.state.checkoutUrl, _checkoutUrl);
  });

  // testWidgets, for its fake clock: pump() is what moves the poll timer.
  testWidgets(
    'after Stripe\'s success page, polls until the server reports PAID, then stops',
    (tester) async {
      final answers = [
        _status(StripePaymentStatus.pending),
        _status(StripePaymentStatus.processing),
        _status(StripePaymentStatus.paid, order: _order),
      ];
      when(() => mockStripe.getStatus('p-1'))
          .thenAnswer((_) async => answers.removeAt(0));

      final cubit = buildCubit();
      cubit.onPaymentSubmitted();

      // Returning from Stripe does not by itself mean paid.
      await tester.pump();
      expect(cubit.state.phase, CardPaymentPhase.confirming);

      await tester.pump(const Duration(seconds: 3));
      expect(cubit.state.phase, CardPaymentPhase.confirming);

      await tester.pump(const Duration(seconds: 3));
      expect(cubit.state.phase, CardPaymentPhase.paid);
      expect(cubit.state.payment?.order?.orderNumber, 'ORD-1');

      await tester.pump(const Duration(minutes: 1));
      verify(() => mockStripe.getStatus('p-1')).called(3);

      cubit.close();
      await tester.pump();
    },
  );

  testWidgets(
    'gives up polling after ten minutes, and "check again" picks it back up',
    (tester) async {
      when(() => mockStripe.getStatus('p-1'))
          .thenAnswer((_) async => _status(StripePaymentStatus.pending));

      final cubit = buildCubit();
      cubit.onPaymentSubmitted();
      await tester.pump(const Duration(minutes: 11));

      expect(cubit.state.phase, CardPaymentPhase.confirming);
      expect(cubit.state.gaveUp, isTrue);

      when(() => mockStripe.getStatus('p-1')).thenAnswer(
        (_) async => _status(StripePaymentStatus.paid, order: _order),
      );
      cubit.checkAgain();
      await tester.pump();

      expect(cubit.state.gaveUp, isFalse);
      expect(cubit.state.phase, CardPaymentPhase.paid);

      cubit.close();
      await tester.pump();
    },
  );

  testWidgets(
    'slows to one check every ten seconds after the first ten',
    (tester) async {
      when(() => mockStripe.getStatus('p-1'))
          .thenAnswer((_) async => _status(StripePaymentStatus.pending));

      final cubit = buildCubit();
      cubit.onPaymentSubmitted();

      // Checks at 0s, 3s, … 27s.
      await tester.pump(const Duration(seconds: 27));
      verify(() => mockStripe.getStatus('p-1')).called(10);

      // The eleventh is due at 37s, not 30s.
      await tester.pump(const Duration(seconds: 9));
      verifyNever(() => mockStripe.getStatus('p-1'));

      await tester.pump(const Duration(seconds: 1));
      verify(() => mockStripe.getStatus('p-1')).called(1);

      cubit.close();
      await tester.pump();
    },
  );

  testWidgets(
    'a failed status check keeps polling instead of ending the payment',
    (tester) async {
      var calls = 0;
      when(() => mockStripe.getStatus('p-1')).thenAnswer((_) async {
        if (calls++ == 0) throw Exception('offline');
        return _status(StripePaymentStatus.paid, order: _order);
      });

      final cubit = buildCubit();
      cubit.onPaymentSubmitted();
      await tester.pump();

      expect(cubit.state.phase, CardPaymentPhase.confirming);
      expect(cubit.state.errorMessage, isNotNull);

      await tester.pump(const Duration(seconds: 3));

      expect(cubit.state.phase, CardPaymentPhase.paid);
      expect(cubit.state.errorMessage, isNull);

      cubit.close();
      await tester.pump();
    },
  );

  test('leaving Stripe\'s page unpaid closes the checkout on the server', () async {
    when(() => mockStripe.cancel('p-1'))
        .thenAnswer((_) async => _status(StripePaymentStatus.cancelled));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.onCheckoutLeft();

    expect(cubit.state.phase, CardPaymentPhase.closed);
    expect(cubit.state.payment?.status, StripePaymentStatus.cancelled);
    expect(cubit.state.isRefunded, isFalse);
    expect(cubit.state.isChecking, isFalse);
    verify(() => mockStripe.cancel('p-1')).called(1);
  });

  test('leaving Stripe\'s page after paying ends up paid, not cancelled', () async {
    // The server settles the order instead of cancelling it.
    when(() => mockStripe.cancel('p-1')).thenAnswer(
      (_) async => _status(StripePaymentStatus.paid, order: _order),
    );
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.onCheckoutLeft();

    expect(cubit.state.phase, CardPaymentPhase.paid);
    expect(cubit.state.payment?.order?.orderNumber, 'ORD-1');
  });

  test('when the server cannot be reached the outcome is unknown, not "nothing charged"', () async {
    when(() => mockStripe.cancel('p-1')).thenThrow(Exception('offline'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.onCheckoutLeft();

    expect(cubit.state.phase, CardPaymentPhase.backedOut);
    expect(cubit.state.isChecking, isFalse);
    expect(cubit.state.payment, isNull);
  });

  test('a checkout the server will not cancel yet keeps being watched', () async {
    // A payment that is still clearing is not the app's to cancel.
    when(() => mockStripe.cancel('p-1'))
        .thenAnswer((_) async => _status(StripePaymentStatus.pending));
    when(() => mockStripe.getStatus('p-1'))
        .thenAnswer((_) async => _status(StripePaymentStatus.pending));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.onCheckoutLeft();

    expect(cubit.state.phase, CardPaymentPhase.confirming);
  });

  test('a charge refunded for lack of stock is closed and flagged as refunded', () async {
    when(() => mockStripe.cancel('p-1')).thenAnswer(
      (_) async => _status(StripePaymentStatus.failed, refunded: true),
    );
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.onCheckoutLeft();

    expect(cubit.state.phase, CardPaymentPhase.closed);
    expect(cubit.state.isRefunded, isTrue);
  });

  test('a payment held for review is reported as reconciling, not as failed', () async {
    when(() => mockStripe.cancel('p-1'))
        .thenAnswer((_) async => _status(StripePaymentStatus.reconciling));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.onCheckoutLeft();

    expect(cubit.state.phase, CardPaymentPhase.reconciling);
  });
}
