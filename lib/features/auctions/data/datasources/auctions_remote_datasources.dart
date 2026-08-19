import 'package:bingo_pay/features/auctions/data/models/auction_model.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../models/auction_detail_model.dart';
import '../models/bid_model.dart';

@injectable
class AuctionsRemoteDatasources {
  final ApiClient _client;

  AuctionsRemoteDatasources(this._client); 

  final baseUrl = "http://13.159.7.199:5001/api/v1";

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
      '$baseUrl/auctions',
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
    final response = await _client.dio.get('$baseUrl/auctions/$uuid');
    final data = response.data;
    final auctionJson = data is Map<String, dynamic> && data['data'] != null
        ? data['data']
        : data;

    return AuctionDetailModel.fromJson(auctionJson);
  }
  
   Future<List<BidModel>> getBids(String auctionUuid) async {
    final response = await _client.dio.get('$baseUrl/auctions/$auctionUuid/bids');
    final data = response.data;
    final bidsJson = data is Map<String, dynamic> && data['data'] != null
        ? data['data']
        : data;

    return (bidsJson as List)
        .map((json) => BidModel.fromJson(json))
        .toList();
  } 

}
