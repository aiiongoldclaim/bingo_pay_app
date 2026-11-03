import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:bingo_pay/features/tvs_wallet/presentation/cubit/tvs_wallet_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements TvsQrDataSource {}

const _summary = {
  'activationRequired': false,
  'wallets': [
    {'uuid': 'home', 'currency': 'INR', 'status': 'ACTIVE'},
    {'uuid': 'other', 'currency': 'SGD', 'status': 'ACTIVE'},
  ],
};

Map<String, dynamic> _page(List<String> ids, String? next) => {
  'items': [
    for (final id in ids) {'id': id},
  ],
  'nextCursor': next,
};

void main() {
  late _MockApi api;
  late TvsWalletCubit cubit;

  setUp(() {
    api = _MockApi();
    when(() => api.walletSummary()).thenAnswer((_) async => Map.of(_summary));
    when(
      () => api.statement(walletUuid: 'home'),
    ).thenAnswer((_) async => _page(['3', '2'], '2'));
    cubit = TvsWalletCubit(api);
  });

  tearDown(() => cubit.close());

  test('loads the balances and the home wallet’s first page', () async {
    await cubit.load();

    expect(cubit.state.home?['uuid'], 'home');
    expect(cubit.state.active, isTrue);
    expect(cubit.state.activity.map((e) => e['id']), ['3', '2']);
    expect(cubit.state.nextCursor, '2');
  });

  test('Load more appends older lines and stops at the end', () async {
    when(
      () => api.statement(walletUuid: 'home', cursor: '2'),
    ).thenAnswer((_) async => _page(['1'], null));
    await cubit.load();

    await cubit.loadMore();
    expect(cubit.state.activity.map((e) => e['id']), ['3', '2', '1']);
    expect(cubit.state.nextCursor, isNull);

    await cubit.loadMore(); // nothing older: no call
    verify(() => api.statement(walletUuid: 'home', cursor: '2')).called(1);
  });

  test('a failed refresh keeps what is on screen', () async {
    await cubit.load();
    when(() => api.walletSummary()).thenThrow(Exception('offline'));

    await cubit.load();
    expect(cubit.state.summary, isNotNull);
    expect(cubit.state.error, isNotNull);
  });
}
