import 'package:bingo_pay/features/home/data/datasource/banner_remote_data_source.dart';
import 'package:bingo_pay/features/home/presentation/cubit/home_banners_cubit.dart';
import 'package:bingo_pay/features/home/presentation/widgets/home_banner_data.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSource extends Mock implements BannerRemoteDataSource {}

void main() {
  late _MockSource source;
  const a = HomeBannerData(id: 'a', imageUrl: 'https://cdn/a.png');
  const b = HomeBannerData(id: 'b', imageUrl: 'https://cdn/b.png');

  setUp(() {
    source = _MockSource();
    when(() => source.trackImpression(any())).thenAnswer((_) async {});
    when(() => source.trackClick(any())).thenAnswer((_) async {});
  });

  blocTest<HomeBannersCubit, List<HomeBannerData>>(
    'shows the API banners',
    setUp: () =>
        when(() => source.getHomeBanners()).thenAnswer((_) async => [a, b]),
    build: () => HomeBannersCubit(source),
    act: (c) => c.load(),
    expect: () => [
      [a, b],
    ],
  );

  blocTest<HomeBannersCubit, List<HomeBannerData>>(
    'falls back to the defaults when the API has none',
    setUp: () =>
        when(() => source.getHomeBanners()).thenAnswer((_) async => []),
    build: () => HomeBannersCubit(source),
    act: (c) => c.load(),
    expect: () => [HomeBanners.defaults],
  );

  blocTest<HomeBannersCubit, List<HomeBannerData>>(
    'falls back to the defaults when the API fails',
    setUp: () =>
        when(() => source.getHomeBanners()).thenThrow(Exception('offline')),
    build: () => HomeBannersCubit(source),
    act: (c) => c.load(),
    expect: () => [HomeBanners.defaults],
  );

  test('counts each banner once per screen view', () {
    final cubit = HomeBannersCubit(source);

    // Swiping a → b → a → b.
    cubit
      ..viewed(a)
      ..viewed(b)
      ..viewed(a)
      ..viewed(b);
    verify(() => source.trackImpression('a')).called(1);
    verify(() => source.trackImpression('b')).called(1);

    // A new screen view (new cubit) counts again.
    HomeBannersCubit(source).viewed(a);
    verify(() => source.trackImpression('a')).called(1);
  });

  test('never tracks the bundled defaults', () {
    final cubit = HomeBannersCubit(source);
    final fallback = HomeBanners.defaults.first;

    cubit
      ..viewed(fallback)
      ..tapped(fallback);

    verifyNever(() => source.trackImpression(any()));
    verifyNever(() => source.trackClick(any()));
  });

  test('counts every tap', () {
    HomeBannersCubit(source)
      ..tapped(a)
      ..tapped(a);

    verify(() => source.trackClick('a')).called(2);
  });
}
