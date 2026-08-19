class AuctionDetailEntity {
  final String uuid;
  final String number;
  final String title;
  final String? slug;
  final List<String>? images;
  final String? itemName;

  final String status;
  final String listingLevel;

  final AuctionDetailCategoryEntity? category;
  final AuctionDetailVendorEntity? vendor;

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
  final String? description;
  final String currency;
  final String type;
  final String itemKind;

  final dynamic product;
  final dynamic service;

  final bool hasReserve;
  final String? reserveStatus;

  final AuctionBidFeeEntity? bidFee;

  final int uniqueBidderCount;
  final int viewCount;

  final AuctionExtensionEntity? extension;

  final int paymentWindowHours;

  final String? startedAt;
  final String? closedAt;
  final String? noWinnerReason;

  final AuctionDetailViewerEntity? viewer;

  final String serverTime;

  AuctionDetailEntity({
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
    this.description,
    required this.currency,
    required this.type,
    required this.itemKind,
    this.product,
    this.service,
    required this.hasReserve,
    this.reserveStatus,
    this.bidFee,
    required this.uniqueBidderCount,
    required this.viewCount,
    this.extension,
    required this.paymentWindowHours,
    this.startedAt,
    this.closedAt,
    this.noWinnerReason,
    this.viewer,
    required this.serverTime,
  });
}


// ============================================================
// CATEGORY
// ============================================================

class AuctionDetailCategoryEntity {
  final String uuid;
  final String name;
  final String slug;

  AuctionDetailCategoryEntity({
    required this.uuid,
    required this.name,
    required this.slug,
  });
}


// ============================================================
// VENDOR
// ============================================================

class AuctionDetailVendorEntity {
  final String uuid;
  final String shopName;

  AuctionDetailVendorEntity({
    required this.uuid,
    required this.shopName,
  });
}


// ============================================================
// BID FEE
// ============================================================

class AuctionBidFeeEntity {
  final bool applies;
  final double percent;
  final String source;

  AuctionBidFeeEntity({
    required this.applies,
    required this.percent,
    required this.source,
  });
}


// ============================================================
// EXTENSION
// ============================================================

class AuctionExtensionEntity {
  final bool enabled;
  final int windowSeconds;
  final int durationSeconds;
  final int timesExtended;
  final String? originalEndAt;

  AuctionExtensionEntity({
    required this.enabled,
    required this.windowSeconds,
    required this.durationSeconds,
    required this.timesExtended,
    this.originalEndAt,
  });
}


// ============================================================
// VIEWER
// ============================================================

class AuctionDetailViewerEntity {
  final bool isEligible;
  final String? ineligibleReason;
  final bool hasBid;
  final bool isHighestBidder;
  final String? highestUserBid;
  final bool isWinner;
  final String? allotmentUuid;
  final String? paymentDueAt;

  AuctionDetailViewerEntity({
    required this.isEligible,
    this.ineligibleReason,
    required this.hasBid,
    required this.isHighestBidder,
    this.highestUserBid,
    required this.isWinner,
    this.allotmentUuid,
    this.paymentDueAt,
  });
}