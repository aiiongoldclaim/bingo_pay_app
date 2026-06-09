import 'package:bingo_pay/core/bloc/app_state.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppState', () {
    test('SuccessState holds data and supports equality', () {
      const s1 = SuccessState<String>('hello');
      const s2 = SuccessState<String>('hello');
      expect(s1, equals(s2));
      expect(s1.data, 'hello');
    });

    test('ErrorState holds failure and supports equality', () {
      const f = NetworkFailure();
      const s1 = ErrorState<String>(f);
      const s2 = ErrorState<String>(f);
      expect(s1, equals(s2));
      expect(s1.failure, isA<NetworkFailure>());
    });

    test('LoadingState instances are equal', () {
      const s1 = LoadingState<String>();
      const s2 = LoadingState<String>();
      expect(s1, equals(s2));
    });
  });
}
