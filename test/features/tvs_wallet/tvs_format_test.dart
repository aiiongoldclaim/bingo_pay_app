import 'package:bingo_pay/features/tvs_wallet/presentation/widgets/tvs_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('activity day headings', () {
    final now = DateTime(2026, 10, 19, 9, 30);
    String day(DateTime d) => tvsDay(d.toUtc().toIso8601String(), now);

    expect(day(DateTime(2026, 10, 19, 0, 5)), 'Today');
    expect(day(DateTime(2026, 10, 18, 23, 55)), 'Yesterday');
    expect(day(DateTime(2026, 10, 17, 12)), '17 Oct');
    expect(day(DateTime(2025, 12, 31, 12)), '31 Dec 2025');
    expect(tvsDay(null, now), 'Earlier');
  });

  test('amounts are grouped and carry their currency', () {
    expect(tvsCoins('1300.00', 'INR'), '₹1,300.00');
    expect(tvsCoins('20', 'SGD'), r'S$20.00');
    expect(tvsCoins('5.5', 'XYZ'), 'XYZ 5.50');
    expect(tvsCoins(null, 'INR'), '—');
  });

  test('typed amounts: 16 whole digits, 2 decimals unless whole', () {
    expect(tvsAmountValid('1234567890123456'), isTrue);
    expect(tvsAmountValid('12345678901234567'), isFalse);
    expect(tvsAmountValid('10.5'), isTrue);
    expect(tvsAmountValid('10.555'), isFalse);
    expect(tvsAmountValid('0.00'), isFalse);
    expect(tvsAmountValid('0.01'), isTrue);
    expect(tvsAmountValid('1,000'), isFalse);
    expect(tvsAmountValid('100.50', whole: true), isFalse);
    expect(tvsAmountValid('100', whole: true), isTrue);
    expect(tvsWholeCurrency('VND'), isTrue);
    expect(tvsWholeCurrency('JPY'), isTrue);
    expect(tvsWholeCurrency('INR'), isFalse);
    expect(tvsWholeCurrency(''), isFalse);
  });

  test('typed amounts are grouped as text, every digit kept', () {
    expect(tvsGroupDigits('200000000'), '200,000,000');
    expect(tvsGroupDigits('1234567890123456.5'), '1,234,567,890,123,456.5');
    expect(tvsGroupDigits('999'), '999');
  });
}
