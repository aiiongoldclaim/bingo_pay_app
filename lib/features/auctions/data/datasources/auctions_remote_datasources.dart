import 'package:bingo_pay/features/auctions/data/models/auction_model.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/auction_detail_model.dart';
import '../models/bid_model.dart';
import '../models/my_bids_model.dart';
import '../models/place_bid_model.dart';

@injectable
class AuctionsRemoteDatasources {
  final ApiClient _client;

  AuctionsRemoteDatasources(this._client);

  Future<List<AuctionModel>> getAuctions({
    int take = 24,
    int skip = 0,
    required String sort,
    String? search,
    String? maxPrice,
    String? minPrice,
    String? listingLevel,
    int? categoryId,
    required String status,
  }) async {
    final response = await _client.dio.get(
      ApiEndpoints.auctions,
      queryParameters: {
        'take': take,
        // 'skip': skip,
        // if(skip != null) 'skip': skip,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
        if (search != null && search.isNotEmpty) 'search': search,
        if (maxPrice != null && maxPrice.isNotEmpty) 'maxPrice': maxPrice,
        if (minPrice != null && minPrice.isNotEmpty) 'minPrice': minPrice,
        if (listingLevel != null && listingLevel.isNotEmpty)
          'listingLevel': listingLevel,
        if (categoryId != null) 'categoryId': categoryId,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final data = response.data;
    final auctionJson = data is Map<String, dynamic> && data['data'] != null
        ? data['data']
        : data;

    // return List<AuctionModel>.from(auctionJson.map((e) => AuctionModel.fromJson(e)));
    return (response.data['data']['items'] as List)
    .map((json) => AuctionModel.fromJson(json))
    .toList();
  }

  Future<AuctionDetailModel> getAuctionDetail(String uuid) async {
    final response = await _client.dio.get(ApiEndpoints.auctionDetail(uuid));
    final data = response.data;
    final auctionJson = data is Map<String, dynamic> && data['data'] != null
        ? data['data']
        : data;

    return AuctionDetailModel.fromJson(auctionJson);
  }

   Future<List<BidModel>> getBids(String auctionUuid) async {
    final response = await _client.dio.get(ApiEndpoints.auctionBids(auctionUuid));
    final data = response.data;
    final bidsJson = data is Map<String, dynamic> && data['data'] != null
        ? data['data']
        : data;

    return (bidsJson as List)
        .map((json) => BidModel.fromJson(json))
        .toList();
  }

  Future<PlaceBidModel> placeBid({
  required String auctionUuid,
  required String amount,
  required String idempotencyKey,
}) async {
  final response = await _client.dio.post(
    ApiEndpoints.auctionBids(auctionUuid),
    data: {
      'amount': amount,
      'idempotencyKey': idempotencyKey,
    },
  );

  final data = response.data;

  final bidJson =
      data is Map<String, dynamic> && data['data'] != null
          ? data['data']
          : data;

  return PlaceBidModel.fromJson(
    bidJson as Map<String, dynamic>,
  );
}

Future<MyBidsModel> getMyBids({
  int take = 20,
  int skip = 0,
  String? state,
}) async {
  final response = await _client.dio.get(
    ApiEndpoints.myAuctionBids,
    queryParameters: {
      'take': take,
      'skip': skip,
      if (state != null && state.isNotEmpty)
        'state': state,
    },
  );

  final data = response.data;

  final myBidsJson =
      data is Map<String, dynamic> && data['data'] != null
          ? data['data']
          : data;

  return MyBidsModel.fromJson(
    myBidsJson as Map<String, dynamic>,
  );
}

}
