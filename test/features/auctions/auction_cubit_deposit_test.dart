import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/features/auctions/data/datasources/auctions_remote_datasources.dart';
import 'package:bingo_pay/features/auctions/data/models/auction_detail_model.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_detail_entity.dart';
import 'package:bingo_pay/features/auctions/domain/entities/place_bid_entity.dart';
import 'package:bingo_pay/features/auctions/domain/repositories/auction_repository.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_cubit.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements AuctionRepository {}

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

// The detail API's bidFee block.
Map<String, dynamic> _fee({required bool paid}) => {
  'applies': true,
  'percent': 5,
  'source': 'auction',
  'baseAmount': '1000.00',
  'amount': '50.00',
  'currency': 'USD',
  'paid': paid,
  'deposit': paid
      ? {
          'uuid': 'd1',
          'status': 'HELD',
          'amount': '50.00',
          'currency': 'USD',
          'provider': 'TVS_WALLET',
          'paidAt': '2026-11-01T10:00:00.000Z',
        }
      : null,
};

AuctionDetailEntity _auction({Map<String, dynamic>? bidFee}) =>
    AuctionDetailModel.fromJson({
      'uuid': 'a1',
      'title': 'Lot',
      'status': 'LIVE',
      'minimumNextBid': '110.00',
      'currency': 'USD',
      'bidFee': ?bidFee,
    }).toEntity();

final _placed = PlaceBidEntity(
  bidUuid: 'b1',
  amount: '120.00',
  sequence: 1,
  currentBid: '120.00',
  minimumNextBid: '130.00',
  bidCount: 1,
  endAt: DateTime(2026, 12),
  extended: false,
  isHighestBidder: true,
);

void main() {
  group('bidFee parsing', () {
    test('reads what the fee is, and the viewer’s paid deposit', () {
      final fee = _auction(bidFee: _fee(paid: true)).bidFee!;

      expect(fee.applies, isTrue);
      expect(fee.percentText, '5');
      expect(fee.amount, '50.00');
      expect(fee.baseAmount, '1000.00');
      expect(fee.currency, 'USD');
      expect(fee.paid, isTrue);
      expect(fee.deposit?.amount, '50.00');
      expect(fee.deposit?.provider, 'TVS_WALLET');
    });

    test('an AUCTION_DEPOSIT_REQUIRED refusal carries the fee to pay', () async {
      final client = _MockApiClient();
      final dio = _MockDio();
      when(() => client.dio).thenReturn(dio);
      final options = RequestOptions(path: '/bids');
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {
              'statusCode': 400,
              'code': 'AUCTION_DEPOSIT_REQUIRED',
              'message': 'Pay USD 50.00 token money to bid.',
              'details': {
                'auctionUuid': 'a1',
                'deposit': {
                  'percent': 5,
                  'source': 'auction',
                  'baseAmount': '1000.00',
                  'amount': '50.00',
                  'currency': 'USD',
                },
              },
            },
          ),
        ),
      );

      final call = AuctionsRemoteDatasources(
        client,
      ).placeBid(auctionUuid: 'a1', amount: '120', idempotencyKey: 'k');

      await expectLater(
        call,
        throwsA(
          isA<AuctionDepositRequired>()
              .having((e) => e.fee.amount, 'amount', '50.00')
              .having((e) => e.fee.applies, 'applies', isTrue)
              .having((e) => e.fee.paid, 'paid', isFalse)
              .having((e) => e.message, 'message', contains('USD 50.00')),
        ),
      );
    });
  });

  group('placing a bid on a lot with a bidding fee', () {
    late _MockRepo repo;
    late AuctionCubit cubit;

    setUp(() {
      repo = _MockRepo();
      cubit = AuctionCubit(repo);
      when(() => repo.getBidsHistory(any())).thenAnswer((_) async => []);
    });

    tearDown(() => cubit.close());

    Future<void> loadWith(AuctionDetailEntity auction) async {
      when(() => repo.fetchAuctionById('a1')).thenAnswer((_) async => auction);
      await cubit.getAuctionDetail('a1');
    }

    test('an unpaid fee asks for the deposit before any bid is sent', () async {
      await loadWith(_auction(bidFee: _fee(paid: false)));

      await cubit.placeBid(auctionId: 'a1', amount: ' 120.00 ');

      final s = cubit.state as AuctionDetailLoaded;
      expect(s.depositDue?.amount, '50.00');
      expect(s.pendingBidAmount, '120.00');
      verifyNever(
        () => repo.placeBid(
          auctionUuid: any(named: 'auctionUuid'),
          amount: any(named: 'amount'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      );
    });

    test(
      'deposit required by the server → paid → the same bid goes in and the '
      'lot reloads',
      () async {
        // The page does not know about the fee; the server does.
        await loadWith(_auction());
        final serverFee = AuctionBidFeeModel.fromJson(
          _fee(paid: false),
        ).toEntity();
        when(
          () => repo.placeBid(
            auctionUuid: 'a1',
            amount: '120.00',
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        ).thenThrow(AuctionDepositRequired(serverFee, 'Pay the token money'));

        await cubit.placeBid(auctionId: 'a1', amount: '120.00');

        var s = cubit.state as AuctionDetailLoaded;
        expect(s.depositDue, same(serverFee));
        expect(s.pendingBidAmount, '120.00');
        expect(s.isPlacingBid, isFalse);
        expect(s.placeBidError, isNull);

        // Paid in the sheet: the server now accepts the bid.
        when(
          () => repo.placeBid(
            auctionUuid: 'a1',
            amount: '120.00',
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        ).thenAnswer((_) async => _placed);
        when(
          () => repo.fetchAuctionById('a1'),
        ).thenAnswer((_) async => _auction(bidFee: _fee(paid: true)));

        await cubit.onDepositClosed(paid: true);

        s = cubit.state as AuctionDetailLoaded;
        expect(s.depositDue, isNull);
        expect(s.pendingBidAmount, isNull);
        expect(s.placedBid, same(_placed));
        expect(s.auction.bidFee?.paid, isTrue);
        verify(
          () => repo.placeBid(
            auctionUuid: 'a1',
            amount: '120.00',
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        ).called(2);
      },
    );

    test('closing the sheet unpaid places nothing', () async {
      await loadWith(_auction(bidFee: _fee(paid: false)));
      await cubit.placeBid(auctionId: 'a1', amount: '120.00');

      await cubit.onDepositClosed(paid: false);

      final s = cubit.state as AuctionDetailLoaded;
      expect(s.depositDue, isNull);
      expect(s.pendingBidAmount, isNull);
      verifyNever(
        () => repo.placeBid(
          auctionUuid: any(named: 'auctionUuid'),
          amount: any(named: 'amount'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      );
    });
  });
}
