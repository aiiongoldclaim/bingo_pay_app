import 'package:bingo_pay/features/auctions/domain/entities/auction_detail_entity.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

import '../../domain/entities/bid_entity.dart';
import '../../domain/entities/my_bids_entity.dart';
import '../../domain/entities/place_bid_entity.dart';
import '../../domain/repositories/auction_repository.dart';
import '../datasources/auctions_remote_datasources.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuctionRepository)
class AuctionRepositoryImpl implements AuctionRepository {
  final AuctionsRemoteDatasources remoteDataSource;

  AuctionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AuctionEntity>> fetchAllAuctions({
    required String status,
    required String sort,
    required int take,
  }) async {
    final result = await remoteDataSource.getAuctions(
      sort: sort,
      status: status,
      take: take,
    );
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<AuctionDetailEntity> fetchAuctionById(String auctionId) async {
    final result = await remoteDataSource.getAuctionDetail(auctionId);
    return result.toEntity();
  }

  @override
  Future<List<BidEntity>> getBidsHistory(String auctionId) async {
    final result = await remoteDataSource.getBids(auctionId);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
Future<PlaceBidEntity> placeBid({
  required String auctionUuid,
  required String amount,
  required String idempotencyKey,
}) async {
  final response = await remoteDataSource.placeBid(
    auctionUuid: auctionUuid,
    amount: amount,
    idempotencyKey: idempotencyKey,
  );

  return response.toEntity();
}

  // ============================================================
  // MY BIDS
  // ============================================================


@override
Future<MyBidsEntity> getMyBids({
  int take = 20,
  int skip = 0,
  String? state,
}) async {
  final model = await remoteDataSource.getMyBids(
    take: take,
    skip: skip,
    state: state,
  );

  return model.toEntity();
}
}
