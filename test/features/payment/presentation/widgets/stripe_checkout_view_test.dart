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

  test('never treats one of NOWPayments\' own pages as the return', () {
    expect(
      stripeReturnOutcome('https://nowpayments.io/payment/?iid=1&from=success'),
      isNull,
    );
    expect(
      stripeReturnOutcome('https://sandbox.nowpayments.io/payment/?from=cancelled'),
      isNull,
    );
  });

  test('hands wallet and app links to the phone, and keeps pages in the WebView', () {
    expect(opensOutsideWebView('bitcoin:bc1qxy2k?amount=0.01'), isTrue);
    expect(opensOutsideWebView('ethereum:0xabc@1?value=1e18'), isTrue);
    expect(opensOutsideWebView('wc:7f6e504b@2?relay-protocol=irn'), isTrue);

    expect(opensOutsideWebView('https://nowpayments.io/payment/?iid=1'), isFalse);
    expect(opensOutsideWebView('https://checkout.stripe.com/c/pay/cs_1'), isFalse);
    expect(opensOutsideWebView('about:blank'), isFalse);
    expect(opensOutsideWebView(''), isFalse);
  });

  test('ignores bank and other pages along the way', () {
    expect(stripeReturnOutcome('https://acs.bank.example/3ds?id=1'), isNull);
    expect(stripeReturnOutcome('$returnUrl?from=successful'), isNull);
    expect(stripeReturnOutcome('$returnUrl?wherefrom=success'), isNull);
    expect(stripeReturnOutcome(''), isNull);
  });
}
