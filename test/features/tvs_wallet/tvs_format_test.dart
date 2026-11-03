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
}
