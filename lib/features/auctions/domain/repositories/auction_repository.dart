import '../entities/auction_entity.dart';

abstract class AuctionRepository {
  Future<List<AuctionEntity>> fetchAllAuctions({
    required String status,
    required String sort,
    required int take,
  });

  // Future<AuctionEntity> fetchAuctionById(String auctionId);

  // Future<void> createNewAuction(AuctionEntity auction);

  // Future<void> updateExistingAuction(String auctionId, AuctionEntity auction);

  // Future<void> deleteAuctionById(String auctionId);
}