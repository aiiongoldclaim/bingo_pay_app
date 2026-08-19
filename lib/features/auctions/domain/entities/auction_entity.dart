class AuctionEntity {
  final String uuid;
  final String number;
  final String title;
  final String? slug;
  final List<String>? images;
  final String? itemName;
  final String status;
  final String listingLevel;

  final AuctionCategoryEntity? category;
  final AuctionVendorEntity? vendor;

  final String startingPrice;
  final String? currentBid;
  final String minimumNextBid;
  final String bidIncrement;
  final String? finalBid;
  final int bidCount;

  final String startAt;
  final String endAt;

  final int? secondsRemaining;
  final int? secondsUntilStart;

  final String badge;
  final AuctionViewerEntity? viewer;

  AuctionEntity({
    required this.uuid,
    required this.number,
    required this.title,
    this.slug,
    this.images,
    this.itemName,
    required this.status,
    required this.listingLevel,
    this.category,
    this.vendor,
    required this.startingPrice,
    this.currentBid,
    required this.minimumNextBid,
    required this.bidIncrement,
    this.finalBid,
    required this.bidCount,
    required this.startAt,
    required this.endAt,
    this.secondsRemaining,
    this.secondsUntilStart,
    required this.badge,
    this.viewer,
  });
}

class AuctionCategoryEntity {
  final String uuid;
  final String name;
  final String slug;

  AuctionCategoryEntity({
    required this.uuid,
    required this.name,
    required this.slug,
  });
}

class AuctionVendorEntity {
  final String uuid;
  final String shopName;

  AuctionVendorEntity({
    required this.uuid,
    required this.shopName,
  });
}

class AuctionViewerEntity {
  final bool hasBid;
  final bool isHighestBidder;
  final String? highestUserBid;

  AuctionViewerEntity({
    required this.hasBid,
    required this.isHighestBidder,
    this.highestUserBid,
  });
}