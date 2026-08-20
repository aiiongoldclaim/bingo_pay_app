class PlaceBidEntity {
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

  const PlaceBidEntity({
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
}