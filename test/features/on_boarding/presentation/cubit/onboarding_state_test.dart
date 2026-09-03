import 'package:bingo_pay/features/on_boarding/presentation/cubit/onboarding_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingState', () {
    test('defaults currentPage to 0', () {
      const state = OnboardingState(totalPages: 3);

      expect(state.currentPage, 0);
      expect(state.totalPages, 3);
    });

    test('isFirstPage is true only when currentPage is 0', () {
      expect(const OnboardingState(totalPages: 3).isFirstPage, isTrue);
      expect(
        const OnboardingState(currentPage: 1, totalPages: 3).isFirstPage,
        isFalse,
      );
    });

    test('isLastPage is true only on the final index', () {
      const state = OnboardingState(currentPage: 2, totalPages: 3);

      expect(state.isLastPage, isTrue);
      expect(state.copyWith(currentPage: 1).isLastPage, isFalse);
    });

    test('isLastPage with a single page: first and last page coincide', () {
      const state = OnboardingState(totalPages: 1);

      expect(state.isFirstPage, isTrue);
      expect(state.isLastPage, isTrue);
    });

    test('copyWith replaces only currentPage and keeps totalPages', () {
      const state = OnboardingState(currentPage: 0, totalPages: 5);

      final next = state.copyWith(currentPage: 2);

      expect(next.currentPage, 2);
      expect(next.totalPages, 5);
    });

    test('copyWith with no args returns an equal state', () {
      const state = OnboardingState(currentPage: 1, totalPages: 5);

      expect(state.copyWith(), equals(state));
    });

    test('two states with the same fields are equal (Equatable)', () {
      const a = OnboardingState(currentPage: 1, totalPages: 3);
      const b = OnboardingState(currentPage: 1, totalPages: 3);

      expect(a, equals(b));
    });

    test('states with different currentPage are not equal', () {
      const a = OnboardingState(currentPage: 0, totalPages: 3);
      const b = OnboardingState(currentPage: 1, totalPages: 3);

      expect(a, isNot(equals(b)));
    });
  });
}
