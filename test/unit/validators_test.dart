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

  group('Validators.phone', () {
    test('returns error for empty value', () {
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone(null), isNotNull);
    });

    test('returns error for non-10-digit value', () {
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('98765432101'), isNotNull);
    });

    test('returns null for a valid 10-digit number', () {
      expect(Validators.phone('9876543210'), isNull);
    });
  });

  group('Validators.gst', () {
    test('returns null when empty (optional field)', () {
      expect(Validators.gst(''), isNull);
      expect(Validators.gst(null), isNull);
    });

    test('returns error for malformed value', () {
      expect(Validators.gst('not-a-gst'), isNotNull);
    });

    test('returns null for a valid GST number', () {
      expect(Validators.gst('22AAAAA0000A1Z5'), isNull);
    });
  });

  group('Validators.pan', () {
    test('returns null when empty (optional field)', () {
      expect(Validators.pan(''), isNull);
      expect(Validators.pan(null), isNull);
    });

    test('returns error for malformed value', () {
      expect(Validators.pan('short'), isNotNull);
    });

    test('returns null for a valid PAN number', () {
      expect(Validators.pan('AAAAA0000A'), isNull);
    });
  });
}
