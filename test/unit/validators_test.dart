import 'package:bingo_pay/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('returns error for empty value', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for invalid email', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('a@'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error when too short', () {
      expect(Validators.password('abc'), isNotNull);
    });
    test('returns null for valid password', () {
      expect(Validators.password('password123'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns error when passwords do not match', () {
      expect(Validators.confirmPassword('abc', 'xyz'), isNotNull);
    });
    test('returns null when passwords match', () {
      expect(Validators.confirmPassword('pass1234', 'pass1234'), isNull);
    });
  });
}
