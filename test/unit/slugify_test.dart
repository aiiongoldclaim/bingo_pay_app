import 'package:bingo_pay/core/utils/slugify.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('slugify', () {
    test('lowercases and replaces spaces with hyphens', () {
      expect(slugify('Acme Store'), 'acme-store');
    });

    test('strips non-alphanumeric characters', () {
      expect(slugify("Acme's Store!!"), 'acme-s-store');
    });

    test('collapses repeated hyphens', () {
      expect(slugify('Acme   Store--Top'), 'acme-store-top');
    });

    test('trims leading and trailing hyphens', () {
      expect(slugify('-Acme Store-'), 'acme-store');
    });
  });
}
