import 'package:bingo_pay/features/auctions/domain/entities/auction_detail_entity.dart';

import '../entities/auction_entity.dart';
import '../entities/bid_entity.dart';

abstract class AuctionRepository {
  Future<List<AuctionEntity>> fetchAllAuctions({
    required String status,
    required String sort,
    required int take,
  });

  Future<AuctionDetailEntity> fetchAuctionById(String auctionId);

  Future<List<BidEntity>> getBidsHistory(String auctionId);

  // Future<void> updateExistingAuction(String auctionId, AuctionEntity auction);

  // Future<void> deleteAuctionById(String auctionId);
}