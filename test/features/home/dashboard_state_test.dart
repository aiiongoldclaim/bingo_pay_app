import 'package:bingo_pay/features/home/presentation/cubit/dashboard_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeState.formattedBigoldBalance', () {
    test('shows every significant digit up to 8 decimal places', () {
      final state = HomeState(bigoldBalance: 0.00000223);
      expect(state.formattedBigoldBalance, '0.00000223 Bigod');
    });

    test('trims trailing zeros past the significant digits', () {
      final state = HomeState(bigoldBalance: 1.23);
      expect(state.formattedBigoldBalance, '1.23 Bigod');
    });

    test("'1.5 Bigod' not '1.50000000 Bigod'", () {
      final state = HomeState(bigoldBalance: 1.5);
      expect(state.formattedBigoldBalance, '1.5 Bigod');
    });

    test('drops the decimal point entirely for a whole number', () {
      final state = HomeState(bigoldBalance: 3.0);
      expect(state.formattedBigoldBalance, '3 Bigod');
    });

    test('never shows more than 8 decimal places', () {
      final state = HomeState(bigoldBalance: 1.123456789);
      final formatted = state.formattedBigoldBalance;
      final numberPart = formatted.split(' ').first;
      final parts = numberPart.split('.');
      final decimals = parts.length > 1 ? parts[1] : '';
      expect(decimals.length <= 8, isTrue,
          reason: 'formatted balance "$formatted" has more than 8 decimals');
    });

    test('zero balance renders as a plain 0.00, not an empty string', () {
      final state = HomeState(bigoldBalance: 0.0);
      expect(state.formattedBigoldBalance, '0.00 Bigod');
    });
  });

  group('HomeState.compactBigoldBalance', () {
    test(
      'a small sub-cent balance is not rounded away to \$0.00 '
      '(matches what Account screen shows for the same account)',
      () {
        final state = HomeState(bigoldBalance: 0.0000225);
        expect(state.compactBigoldBalance, '\$0.0000225');
      },
    );

    test('trims trailing zeros the same way as formattedBigoldBalance', () {
      final state = HomeState(bigoldBalance: 1.5);
      expect(state.compactBigoldBalance, '\$1.5');
    });

    test('zero balance renders as \$0.00', () {
      final state = HomeState(bigoldBalance: 0.0);
      expect(state.compactBigoldBalance, '\$0.00');
    });
  });
}
