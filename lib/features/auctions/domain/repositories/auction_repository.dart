import 'package:bingo_pay/features/auctions/domain/entities/auction_detail_entity.dart';

import '../entities/allotment_payment_entity.dart';
import '../entities/auction_entity.dart';
import '../entities/bid_entity.dart';
import '../entities/my_bids_entity.dart';
import '../entities/place_bid_entity.dart';

abstract class AuctionRepository {
  Future<List<AuctionEntity>> fetchAllAuctions({
    required String status,
    required String sort,
    required int take,
  });

  Future<AuctionDetailEntity> fetchAuctionById(String auctionId);

  Future<List<BidEntity>> getBidsHistory(String auctionId);

  Future<PlaceBidEntity> placeBid({
  required String auctionUuid,
  required String amount,
  required String idempotencyKey,
});

Future<MyBidsEntity> getMyBids({
  int take = 20,
  int skip = 0,
  String? state,
});

/// Creates a BIGOD payment quote for a won auction's allotment.
Future<AllotmentPaymentEntity> payAllotment({
  required String allotmentUuid,
  required String idempotencyKey,
});

Future<double> getBigodTokenBalance();

Future<void> confirmBigodPayment(String token);

  // Future<void> updateExistingAuction(String auctionId, AuctionEntity auction);

  // Future<void> deleteAuctionById(String auctionId);
}