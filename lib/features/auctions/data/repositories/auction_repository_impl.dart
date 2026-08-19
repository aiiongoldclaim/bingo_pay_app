import 'package:bingo_pay/features/auctions/domain/entities/auction_detail_entity.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

import '../../domain/entities/bid_entity.dart';
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
}
