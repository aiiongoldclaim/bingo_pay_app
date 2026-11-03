import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/features/auctions/data/datasources/auctions_remote_datasources.dart';
import 'package:bingo_pay/features/auctions/presentation/widgets/auction_tvs_pay.dart';
import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

void main() {
  group('loadTvsQuote', () {
    test('passes a quote through', () async {
      final q = await loadTvsQuote(() async => {'canPay': true});
      expect(q, {'canPay': true});
    });

    test('TVS Wallet switched off for the account hides the option', () async {
      final q = await loadTvsQuote(
        () async => throw const TvsQrException('FEATURE_DISABLED', 'Off'),
      );
      expect(q, isNull);
    });

    test('any other failure shows the option with the reason', () async {
      final q = await loadTvsQuote(
        () async => throw const TvsQrException(
          'AUCTION_DEPOSIT_NOT_PAYABLE',
          'Bidding on this lot has closed.',
        ),
      );
      expect(q, {'canPay': false, 'reason': 'Bidding on this lot has closed.'});
    });
  });

  test('the option line shows coins, balance and the MPIN rule', () {
    expect(tvsQuoteLine(null), 'Checking your TVS Coins…');
    expect(
      tvsQuoteLine({'canPay': false, 'reason': 'Verify your wallet first'}),
      'Verify your wallet first',
    );
    expect(
      tvsQuoteLine({
        'canPay': true,
        'coins': {'total': '1300.00', 'available': '2000.00', 'currency': 'USD'},
        'pin': {'required': true},
      }),
      r'$1,300.00 · Balance $2,000.00 · MPIN needed',
    );
  });

  test('a won lot paid in TVS Coins: coded refusals keep their code', () async {
    final client = _MockApiClient();
    final dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    final options = RequestOptions(path: ApiEndpoints.tvsAuctionPay('al1'));
    when(
      () => dio.post(ApiEndpoints.tvsAuctionPay('al1'), data: any(named: 'data')),
    ).thenThrow(
      DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 409,
          data: {'code': 'QUOTE_CHANGED', 'message': 'The price changed.'},
        ),
      ),
    );

    await expectLater(
      AuctionsRemoteDatasources(client).tvsAllotmentPay('al1', {
        'idempotencyKey': 'k',
        'expectedCoins': '1300.00',
      }),
      throwsA(
        isA<TvsQrException>()
            .having((e) => e.code, 'code', 'QUOTE_CHANGED')
            .having((e) => e.message, 'message', 'The price changed.'),
      ),
    );
  });
}
