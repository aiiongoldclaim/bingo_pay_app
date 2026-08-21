class MyBidsEntity {
  final List<MyBidItemEntity> items;
  final int total;
  final MyBidsSummaryEntity summary;

  MyBidsEntity({
    required this.items,
    required this.total,
    required this.summary,
  });
}

// ============================================================
// MY BID ITEM
// ============================================================

class MyBidItemEntity {
  final String uuid;
  final String number;
  final String title;
  final String? slug;
  final List<String>? images;
  final String? itemName;

  final String status;
  final String listingLevel;

  final MyBidCategoryEntity? category;
  final MyBidVendorEntity? vendor;

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
  final String currency;

  final String? myHighestBid;
  final int myBidCount;
  final String? myLastBidAt;
  final String? myBidFeesPaid;
  final int myBidFeeCount;

  final String myStatus;

  final MyBidAllotmentEntity? allotment;

  MyBidItemEntity({
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
    required this.currency,
    this.myHighestBid,
    required this.myBidCount,
    this.myLastBidAt,
    this.myBidFeesPaid,
    required this.myBidFeeCount,
    required this.myStatus,
    this.allotment,
  });
}

// ============================================================
// CATEGORY
// ============================================================

class MyBidCategoryEntity {
  final String uuid;
  final String name;
  final String slug;

  MyBidCategoryEntity({
    required this.uuid,
    required this.name,
    required this.slug,
  });
}

// ============================================================
// VENDOR
// ============================================================

class MyBidVendorEntity {
  final String uuid;
  final String shopName;

  MyBidVendorEntity({
    required this.uuid,
    required this.shopName,
  });
}

// ============================================================
// ALLOTMENT
// ============================================================

class MyBidAllotmentEntity {
  final String uuid;
  final String status;
  final String amount;
  final String paymentDueAt;
  final int rank;
  final bool isOverdue;

  MyBidAllotmentEntity({
    required this.uuid,
    required this.status,
    required this.amount,
    required this.paymentDueAt,
    required this.rank,
    required this.isOverdue,
  });
}

// ============================================================
// SUMMARY
// ============================================================

class MyBidsSummaryEntity {
  final int leading;
  final int outbid;
  final int won;
  final int paymentDue;
  final int lost;

  MyBidsSummaryEntity({
    required this.leading,
    required this.outbid,
    required this.won,
    required this.paymentDue,
    required this.lost,
  });
}