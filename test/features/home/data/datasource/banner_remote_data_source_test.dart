import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/features/home/data/datasource/banner_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late BannerRemoteDataSource source;

  setUp(() {
    dio = _MockDio();
    final client = _MockApiClient();
    when(() => client.dio).thenReturn(dio);
    source = BannerRemoteDataSource(client);
  });

  void stubGet(Object? body) => when(
    () => dio.get(
      ApiEndpoints.banners,
      queryParameters: any(named: 'queryParameters'),
    ),
  ).thenAnswer(
    (_) async => Response(
      requestOptions: RequestOptions(path: ApiEndpoints.banners),
      data: body,
    ),
  );

  final banner = {'uuid': 'b-1', 'imageUrl': 'https://cdn/b.png'};

  test('asks for HOME/MOBILE and reads the envelope list', () async {
    stubGet({
      'success': true,
      'data': [
        banner,
        {'uuid': 'b-2'}, // no image: skipped
      ],
    });

    final list = await source.getHomeBanners();

    expect(list.map((b) => b.id), ['b-1']);
    final query = verify(
      () => dio.get(
        ApiEndpoints.banners,
        queryParameters: captureAny(named: 'queryParameters'),
      ),
    ).captured.single;
    expect(query, {'placement': 'HOME', 'device': 'MOBILE'});
  });

  test('reads a double-wrapped list', () async {
    stubGet({
      'data': {
        'data': [banner],
      },
    });

    expect((await source.getHomeBanners()).single.id, 'b-1');
  });

  test('tracking never throws', () async {
    when(() => dio.post(any())).thenThrow(
      DioException(requestOptions: RequestOptions(path: '')),
    );

    await source.trackImpression('b-1');
    await source.trackClick('b-1');

    verify(() => dio.post(ApiEndpoints.bannerImpression('b-1'))).called(1);
    verify(() => dio.post(ApiEndpoints.bannerClick('b-1'))).called(1);
  });
}
