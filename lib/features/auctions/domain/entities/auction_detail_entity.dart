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

// The advance bidding fee ("token money"): `percent` of `baseAmount` (the
// starting price), paid once before a bidder's first bid. Amounts are the
// API's 2-decimal strings.
class AuctionBidFeeEntity {
  final bool applies;
  final double percent;
  final String source;
  final String? amount;
  final String? baseAmount;
  final String currency;
  // This viewer has paid it (always false when signed out).
  final bool paid;
  final AuctionDepositEntity? deposit;

  AuctionBidFeeEntity({
    required this.applies,
    required this.percent,
    required this.source,
    this.amount,
    this.baseAmount,
    this.currency = '',
    this.paid = false,
    this.deposit,
  });

  // "5" rather than "5.0".
  String get percentText =>
      percent % 1 == 0 ? percent.toStringAsFixed(0) : '$percent';
}

// The viewer's own deposit on this lot.
class AuctionDepositEntity {
  final String uuid;
  final String status;
  final String amount;
  final String currency;
  final String? provider;
  final String? paidAt;

  AuctionDepositEntity({
    required this.uuid,
    required this.status,
    required this.amount,
    required this.currency,
    this.provider,
    this.paidAt,
  });
}

// A bid refused with AUCTION_DEPOSIT_REQUIRED: `fee` is the server's figure
// for the deposit to pay first.
class AuctionDepositRequired implements Exception {
  final AuctionBidFeeEntity fee;
  final String message;

  AuctionDepositRequired(this.fee, this.message);

  @override
  String toString() => message;
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