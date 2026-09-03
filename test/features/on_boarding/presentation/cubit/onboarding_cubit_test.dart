import 'package:bingo_pay/features/on_boarding/data/model/on_boarding_feature.dart';
import 'package:bingo_pay/features/on_boarding/presentation/cubit/onboarding_cubit.dart';
import 'package:bingo_pay/features/on_boarding/presentation/cubit/onboarding_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // OnboardingCubit's initial state is derived from the real content list,
  // so tests key off its length rather than a hardcoded number.
  final totalPages = OnBoardingContent.contents.length;

  group('OnboardingCubit', () {
    test('initial state starts at page 0 with the real content length', () {
      final cubit = OnboardingCubit();

      expect(cubit.state.currentPage, 0);
      expect(cubit.state.totalPages, totalPages);

      cubit.close();
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'onPageChanged emits a state with the new currentPage',
      build: OnboardingCubit.new,
      act: (cubit) => cubit.onPageChanged(1),
      expect: () => [isA<OnboardingState>().having(
        (s) => s.currentPage,
        'currentPage',
        1,
      )],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'onPageChanged is a no-op when the index matches the current page',
      build: OnboardingCubit.new,
      act: (cubit) => cubit.onPageChanged(0),
      expect: () => <OnboardingState>[],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'goNext advances the page and returns false when not on the last page',
      build: OnboardingCubit.new,
      act: (cubit) {
        final finished = cubit.goNext();
        expect(finished, isFalse);
      },
      expect: () => [isA<OnboardingState>().having(
        (s) => s.currentPage,
        'currentPage',
        1,
      )],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'goNext on the last page returns true and emits nothing',
      build: OnboardingCubit.new,
      seed: () => OnboardingState(
        currentPage: totalPages - 1,
        totalPages: totalPages,
      ),
      act: (cubit) {
        final finished = cubit.goNext();
        expect(finished, isTrue);
      },
      expect: () => <OnboardingState>[],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'goBack moves to the previous page',
      build: OnboardingCubit.new,
      seed: () => OnboardingState(currentPage: 1, totalPages: totalPages),
      act: (cubit) => cubit.goBack(),
      expect: () => [isA<OnboardingState>().having(
        (s) => s.currentPage,
        'currentPage',
        0,
      )],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'goBack on the first page is a no-op and emits nothing',
      build: OnboardingCubit.new,
      act: (cubit) => cubit.goBack(),
      expect: () => <OnboardingState>[],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'goNext repeated calls walk through every page then report finished '
      'exactly once on the last page',
      build: OnboardingCubit.new,
      act: (cubit) {
        final total = cubit.state.totalPages;
        final results = <bool>[];
        for (var i = 0; i < total; i++) {
          results.add(cubit.goNext());
        }
        // Only the very last call (from the last page) should report finished.
        expect(
          results,
          List.generate(total, (i) => i == total - 1),
        );
      },
      verify: (cubit) {
        expect(cubit.state.isLastPage, isTrue);
      },
    );
  });
}
