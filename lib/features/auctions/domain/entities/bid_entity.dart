class BidEntity {
  final String uuid;
  final String amount;
  final int sequence;
  final String placedAt;
  final BidderEntity? bidder;

  const BidEntity({
    required this.uuid,
    required this.amount,
    required this.sequence,
    required this.placedAt,
    this.bidder,
  });
}

class BidderEntity {
  final String alias;
  final String maskedName;

  const BidderEntity({
    required this.alias,
    required this.maskedName,
  });
}