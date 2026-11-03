import 'package:flutter_test/flutter_test.dart';
import 'package:bingo_pay/features/scanner/presentation/widgets/kyc_number.dart';

// Mirrors backend tvs-kyc-number.rules.spec.ts (the customer side). Presets
// are written out as GET /tvs-wallet/kyc/requirements sends them.
const _presets = <String, Map<String, dynamic>>{
  'AADHAAR': {
    'preset': 'AADHAAR',
    'chars': 'DIGITS',
    'minLength': 12,
    'maxLength': 12,
    'pattern': r'^[2-9][0-9]{11}$',
    'checksum': 'VERHOEFF',
    'example': '2345 6789 0124',
    'message': 'Enter the 12-digit number on your Aadhaar card',
  },
  'PAN': {
    'preset': 'PAN',
    'mask': 'AAAAA9999A',
    'pattern': r'^[A-Z]{3}[ABCFGHJLPT][A-Z][0-9]{4}[A-Z]$',
    'example': 'ABCPE1234F',
    'message': 'Enter the 10-character PAN, like ABCPE1234F',
  },
  'GSTIN': {
    'preset': 'GSTIN',
    'minLength': 15,
    'maxLength': 15,
    'pattern': r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
    'checksum': 'GSTIN',
    'example': '27AAPFU0939F1ZV',
    'message': 'Enter the 15-character GSTIN on the certificate',
  },
  'PASSPORT_IN': {'mask': 'A9999999', 'example': 'M1234567'},
  'VOTER_ID_IN': {'mask': 'AAA9999999', 'example': 'ABC1234567'},
  'DRIVING_LICENCE_IN': {
    'pattern': r'^[A-Z]{2}[0-9]{13,14}$',
    'example': 'MH12 20110012345',
  },
  'NRIC': {
    'pattern': r'^[STFGM][0-9]{7}[A-Z]$',
    'checksum': 'NRIC',
    'example': 'S1234567D',
  },
  'EMIRATES_ID': {
    'chars': 'DIGITS',
    'minLength': 15,
    'maxLength': 15,
    'pattern': r'^784[0-9]{12}$',
    'checksum': 'LUHN',
    'example': '784-1990-1234567-6',
  },
};

void main() {
  group('a document with no rule', () {
    test('keeps the general check: 4 to 32 letters and digits', () {
      expect(numberProblem(null, 'AB12', 'ID'), isNull);
      expect(numberProblem({}, 'ab-12 34', 'ID'), isNull);
      expect(numberProblem(null, 'AB1', 'ID'), 'Enter a valid ID number');
      expect(numberProblem(null, 'AB#12', 'ID'), 'Enter a valid ID number');
      expect(numberProblem(null, 'A' * 33, 'ID'), 'Enter a valid ID number');
    });

    test('normalises spaces, hyphens and case', () {
      expect(normaliseNumber(' ab-12 cd '), 'AB12CD');
      expect(normaliseNumber(null), '');
    });
  });

  group('presets', () {
    for (final MapEntry(key: name, value: rule) in _presets.entries) {
      test('$name: its own example passes', () {
        expect(numberProblem(rule, rule['example'] as String, name), isNull);
      });
    }

    test('Aadhaar: 12 digits with a valid check digit, spaces allowed', () {
      final aadhaar = _presets['AADHAAR'];
      expect(numberProblem(aadhaar, '2345 6789 0124', 'Aadhaar'), isNull);
      // One digit off: the check digit catches it.
      expect(numberProblem(aadhaar, '2345 6789 0125', 'Aadhaar'), isNotNull);
      expect(numberProblem(aadhaar, '234567890', 'Aadhaar'), isNotNull);
      expect(
        numberProblem(aadhaar, 'ABCD', 'Aadhaar'),
        'Enter the 12-digit number on your Aadhaar card',
      );
    });

    test('PAN: AAAAA9999A with a known holder type', () {
      final pan = _presets['PAN'];
      expect(numberProblem(pan, 'abcpe1234f', 'PAN'), isNull);
      expect(numberProblem(pan, 'ABCDE12345', 'PAN'), isNotNull);
      expect(numberProblem(pan, 'ABCXE1234F', 'PAN'), isNotNull);
    });

    test(
      'GSTIN and NRIC: published samples pass, a changed character fails',
      () {
        expect(
          numberProblem(_presets['GSTIN'], '27AAPFU0939F1ZV', 'G'),
          isNull,
        );
        expect(
          numberProblem(_presets['GSTIN'], '27AAPFU0939F1ZW', 'G'),
          isNotNull,
        );
        expect(numberProblem(_presets['NRIC'], 'S1234567D', 'N'), isNull);
        expect(
          numberProblem(_presets['NRIC'], 'S1234567A', 'N'),
          'That N number isn’t valid. Check each character',
        );
      },
    );

    test('Emirates ID: a changed digit fails the Luhn check', () {
      expect(
        numberProblem(_presets['EMIRATES_ID'], '784-1990-1234567-5', 'EID'),
        'That EID number isn’t valid. Check each character',
      );
    });
  });

  group('a rule the admin wrote', () {
    test('characters and length', () {
      const rule = {'chars': 'DIGITS', 'minLength': 6, 'maxLength': 8};
      expect(numberProblem(rule, '123456', 'Licence'), isNull);
      expect(
        numberProblem(rule, '12345A', 'Licence'),
        'The Licence number has digits only',
      );
      expect(
        numberProblem(rule, '12345', 'Licence'),
        'The Licence number has at least 6 characters',
      );
      expect(
        numberProblem(rule, '123456789', 'Licence'),
        'The Licence number has at most 8 characters',
      );
      expect(
        numberProblem({'chars': 'LETTERS'}, 'AB12', 'Code'),
        'The Code number has letters only',
      );
    });

    test('a mask sets the shape and the length', () {
      expect(maskToPattern('AA99*'), r'^[A-Z][A-Z][0-9][0-9][A-Z0-9]$');
      expect(numberProblem({'mask': 'AA99'}, 'mh12', 'Code'), isNull);
      expect(
        numberProblem({'mask': 'AA99'}, 'M112', 'Code'),
        'The Code number looks like AA99',
      );
      expect(
        numberProblem({'mask': 'AA99'}, 'MH123', 'Code'),
        'The Code number has 4 characters',
      );
    });

    test('a custom pattern, with the admin message', () {
      const rule = {'pattern': r'^TL[0-9]{6}$', 'message': 'Starts with TL'};
      expect(numberProblem(rule, 'TL123456', 'Trade licence'), isNull);
      expect(
        numberProblem(rule, 'XX123456', 'Trade licence'),
        'Starts with TL',
      );
      // A pattern that does not compile is skipped, not a refusal.
      expect(numberProblem({'pattern': '^[A-Z'}, 'AB12', 'X'), isNull);
    });

    test('part of one number must equal the number of another document', () {
      final gst = {
        ..._presets['GSTIN']!,
        'matches': {'code': 'BUSINESS_PAN', 'start': 3, 'length': 10},
      };
      const labels = {'BUSINESS_PAN': 'Business PAN card'};
      const number = '27AAPFU0939F1ZV';
      expect(
        numberProblem(gst, number, 'GST', {
          'BUSINESS_PAN': 'AAPFU0939F',
        }, labels),
        isNull,
      );
      expect(
        numberProblem(gst, number, 'GST', {
          'BUSINESS_PAN': 'ABCPE1234F',
        }, labels),
        'The GST number doesn’t match your Business PAN card',
      );
      // The other document was not given: nothing to compare with.
      expect(numberProblem(gst, number, 'GST'), isNull);
    });
  });
}
