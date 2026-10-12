import 'package:bingo_pay/features/payment/presentation/widgets/stripe_checkout_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const returnUrl =
      'https://shop.example.com/customer/payments/card/9f8e7d6c-1111-2222';

  test('recognises the page Stripe returns to after paying', () {
    expect(
      stripeReturnOutcome('$returnUrl?from=success'),
      StripeCheckoutReturn.success,
    );
  });

  test('recognises the page Stripe returns to when the customer backs out', () {
    expect(
      stripeReturnOutcome('$returnUrl?from=cancelled'),
      StripeCheckoutReturn.cancelled,
    );
  });

  test('still recognises it when something follows the marker', () {
    expect(
      stripeReturnOutcome('$returnUrl?x=1&from=success&y=2'),
      StripeCheckoutReturn.success,
    );
    expect(
      stripeReturnOutcome('$returnUrl?from=cancelled#top'),
      StripeCheckoutReturn.cancelled,
    );
  });

  test('never treats one of Stripe\'s own pages as the return', () {
    expect(
      stripeReturnOutcome('https://checkout.stripe.com/c/pay/cs_test_1?from=success'),
      isNull,
    );
    expect(stripeReturnOutcome('https://stripe.com/legal?from=success'), isNull);
  });

  test('ignores bank and other pages along the way', () {
    expect(stripeReturnOutcome('https://acs.bank.example/3ds?id=1'), isNull);
    expect(stripeReturnOutcome('$returnUrl?from=successful'), isNull);
    expect(stripeReturnOutcome('$returnUrl?wherefrom=success'), isNull);
    expect(stripeReturnOutcome(''), isNull);
  });
}
