import '../../domain/entities/place_bid_entity.dart';

class PlaceBidModel {
  final String bidUuid;
  final String amount;
  final int sequence;
  final String currentBid;
  final String minimumNextBid;
  final int bidCount;
  final DateTime endAt;
  final bool extended;
  final bool isHighestBidder;
  final dynamic fee;

  const PlaceBidModel({
    required this.bidUuid,
    required this.amount,
    required this.sequence,
    required this.currentBid,
    required this.minimumNextBid,
    required this.bidCount,
    required this.endAt,
    required this.extended,
    required this.isHighestBidder,
    this.fee,
  });

  factory PlaceBidModel.fromJson(Map<String, dynamic> json) {
    return PlaceBidModel(
      bidUuid: json['bidUuid']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      sequence: json['sequence'] ?? 0,
      currentBid: json['currentBid']?.toString() ?? '0',
      minimumNextBid: json['minimumNextBid']?.toString() ?? '0',
      bidCount: json['bidCount'] ?? 0,
      endAt: DateTime.parse(json['endAt']),
      extended: json['extended'] ?? false,
      isHighestBidder: json['isHighestBidder'] ?? false,
      fee: json['fee'],
    );
  }

  PlaceBidEntity toEntity() {
    return PlaceBidEntity(
      bidUuid: bidUuid,
      amount: amount,
      sequence: sequence,
      currentBid: currentBid,
      minimumNextBid: minimumNextBid,
      bidCount: bidCount,
      endAt: endAt,
      extended: extended,
      isHighestBidder: isHighestBidder,
      fee: fee,
    );
  }
}