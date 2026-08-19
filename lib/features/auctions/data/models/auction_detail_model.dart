import '../../domain/entities/auction_detail_entity.dart';

class AuctionDetailModel {
  final String uuid;
  final String number;
  final String title;
  final String? slug;
  final List<String>? images;
  final String? itemName;

  final String status;
  final String listingLevel;

  final AuctionDetailCategoryModel? category;
  final AuctionDetailVendorModel? vendor;

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

  final AuctionBidFeeModel? bidFee;

  final int uniqueBidderCount;
  final int viewCount;

  final AuctionExtensionModel? extension;

  final int paymentWindowHours;

  final String? startedAt;
  final String? closedAt;
  final String? noWinnerReason;

  final AuctionDetailViewerModel? viewer;

  final String serverTime;

  AuctionDetailModel({
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

  /// 🔁 JSON → Model
  factory AuctionDetailModel.fromJson(Map<String, dynamic> json) {
    return AuctionDetailModel(
      uuid: json['uuid']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),

      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,

      itemName: json['itemName']?.toString(),

      status: json['status']?.toString() ?? '',
      listingLevel: json['listingLevel']?.toString() ?? '',

      category: json['category'] != null
          ? AuctionDetailCategoryModel.fromJson(json['category'])
          : null,

      vendor: json['vendor'] != null
          ? AuctionDetailVendorModel.fromJson(json['vendor'])
          : null,

      startingPrice: json['startingPrice']?.toString() ?? '',
      currentBid: json['currentBid']?.toString(),

      minimumNextBid: json['minimumNextBid']?.toString() ?? '',
      bidIncrement: json['bidIncrement']?.toString() ?? '',

      finalBid: json['finalBid']?.toString(),

      bidCount: json['bidCount'] ?? 0,

      startAt: json['startAt']?.toString() ?? '',
      endAt: json['endAt']?.toString() ?? '',

      secondsRemaining: json['secondsRemaining'],
      secondsUntilStart: json['secondsUntilStart'],

      badge: json['badge']?.toString() ?? '',

      description: json['description']?.toString(),

      currency: json['currency']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      itemKind: json['itemKind']?.toString() ?? '',

      product: json['product'],
      service: json['service'],

      hasReserve: json['hasReserve'] ?? false,
      reserveStatus: json['reserveStatus']?.toString(),

      bidFee: json['bidFee'] != null
          ? AuctionBidFeeModel.fromJson(json['bidFee'])
          : null,

      uniqueBidderCount: json['uniqueBidderCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,

      extension: json['extension'] != null
          ? AuctionExtensionModel.fromJson(json['extension'])
          : null,

      paymentWindowHours: json['paymentWindowHours'] ?? 0,

      startedAt: json['startedAt']?.toString(),
      closedAt: json['closedAt']?.toString(),
      noWinnerReason: json['noWinnerReason']?.toString(),

      viewer: json['viewer'] != null
          ? AuctionDetailViewerModel.fromJson(json['viewer'])
          : null,

      serverTime: json['serverTime']?.toString() ?? '',
    );
  }

  /// 🔁 Model → JSON
  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "number": number,
      "title": title,
      "slug": slug,
      "images": images,
      "itemName": itemName,
      "status": status,
      "listingLevel": listingLevel,
      "category": category?.toJson(),
      "vendor": vendor?.toJson(),
      "startingPrice": startingPrice,
      "currentBid": currentBid,
      "minimumNextBid": minimumNextBid,
      "bidIncrement": bidIncrement,
      "finalBid": finalBid,
      "bidCount": bidCount,
      "startAt": startAt,
      "endAt": endAt,
      "secondsRemaining": secondsRemaining,
      "secondsUntilStart": secondsUntilStart,
      "badge": badge,
      "description": description,
      "currency": currency,
      "type": type,
      "itemKind": itemKind,
      "product": product,
      "service": service,
      "hasReserve": hasReserve,
      "reserveStatus": reserveStatus,
      "bidFee": bidFee?.toJson(),
      "uniqueBidderCount": uniqueBidderCount,
      "viewCount": viewCount,
      "extension": extension?.toJson(),
      "paymentWindowHours": paymentWindowHours,
      "startedAt": startedAt,
      "closedAt": closedAt,
      "noWinnerReason": noWinnerReason,
      "viewer": viewer?.toJson(),
      "serverTime": serverTime,
    };
  }

  /// 🔁 Model → Entity
  AuctionDetailEntity toEntity() {
    return AuctionDetailEntity(
      uuid: uuid,
      number: number,
      title: title,
      slug: slug,
      images: images,
      itemName: itemName,
      status: status,
      listingLevel: listingLevel,
      category: category?.toEntity(),
      vendor: vendor?.toEntity(),
      startingPrice: startingPrice,
      currentBid: currentBid,
      minimumNextBid: minimumNextBid,
      bidIncrement: bidIncrement,
      finalBid: finalBid,
      bidCount: bidCount,
      startAt: startAt,
      endAt: endAt,
      secondsRemaining: secondsRemaining,
      secondsUntilStart: secondsUntilStart,
      badge: badge,
      description: description,
      currency: currency,
      type: type,
      itemKind: itemKind,
      product: product,
      service: service,
      hasReserve: hasReserve,
      reserveStatus: reserveStatus,
      bidFee: bidFee?.toEntity(),
      uniqueBidderCount: uniqueBidderCount,
      viewCount: viewCount,
      extension: extension?.toEntity(),
      paymentWindowHours: paymentWindowHours,
      startedAt: startedAt,
      closedAt: closedAt,
      noWinnerReason: noWinnerReason,
      viewer: viewer?.toEntity(),
      serverTime: serverTime,
    );
  }

  /// 🔁 Entity → Model
  factory AuctionDetailModel.fromEntity(
    AuctionDetailEntity entity,
  ) {
    return AuctionDetailModel(
      uuid: entity.uuid,
      number: entity.number,
      title: entity.title,
      slug: entity.slug,
      images: entity.images,
      itemName: entity.itemName,
      status: entity.status,
      listingLevel: entity.listingLevel,

      category: entity.category != null
          ? AuctionDetailCategoryModel.fromEntity(entity.category!)
          : null,

      vendor: entity.vendor != null
          ? AuctionDetailVendorModel.fromEntity(entity.vendor!)
          : null,

      startingPrice: entity.startingPrice,
      currentBid: entity.currentBid,
      minimumNextBid: entity.minimumNextBid,
      bidIncrement: entity.bidIncrement,
      finalBid: entity.finalBid,
      bidCount: entity.bidCount,

      startAt: entity.startAt,
      endAt: entity.endAt,

      secondsRemaining: entity.secondsRemaining,
      secondsUntilStart: entity.secondsUntilStart,

      badge: entity.badge,
      description: entity.description,
      currency: entity.currency,
      type: entity.type,
      itemKind: entity.itemKind,

      product: entity.product,
      service: entity.service,

      hasReserve: entity.hasReserve,
      reserveStatus: entity.reserveStatus,

      bidFee: entity.bidFee != null
          ? AuctionBidFeeModel.fromEntity(entity.bidFee!)
          : null,

      uniqueBidderCount: entity.uniqueBidderCount,
      viewCount: entity.viewCount,

      extension: entity.extension != null
          ? AuctionExtensionModel.fromEntity(entity.extension!)
          : null,

      paymentWindowHours: entity.paymentWindowHours,

      startedAt: entity.startedAt,
      closedAt: entity.closedAt,
      noWinnerReason: entity.noWinnerReason,

      viewer: entity.viewer != null
          ? AuctionDetailViewerModel.fromEntity(entity.viewer!)
          : null,

      serverTime: entity.serverTime,
    );
  }
}


// ============================================================
// CATEGORY
// ============================================================

class AuctionDetailCategoryModel {
  final String uuid;
  final String name;
  final String slug;

  AuctionDetailCategoryModel({
    required this.uuid,
    required this.name,
    required this.slug,
  });

  factory AuctionDetailCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuctionDetailCategoryModel(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "name": name,
      "slug": slug,
    };
  }

  AuctionDetailCategoryEntity toEntity() {
    return AuctionDetailCategoryEntity(
      uuid: uuid,
      name: name,
      slug: slug,
    );
  }

  factory AuctionDetailCategoryModel.fromEntity(
    AuctionDetailCategoryEntity entity,
  ) {
    return AuctionDetailCategoryModel(
      uuid: entity.uuid,
      name: entity.name,
      slug: entity.slug,
    );
  }
}


// ============================================================
// VENDOR
// ============================================================

class AuctionDetailVendorModel {
  final String uuid;
  final String shopName;

  AuctionDetailVendorModel({
    required this.uuid,
    required this.shopName,
  });

  factory AuctionDetailVendorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuctionDetailVendorModel(
      uuid: json['uuid']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "shopName": shopName,
    };
  }

  AuctionDetailVendorEntity toEntity() {
    return AuctionDetailVendorEntity(
      uuid: uuid,
      shopName: shopName,
    );
  }

  factory AuctionDetailVendorModel.fromEntity(
    AuctionDetailVendorEntity entity,
  ) {
    return AuctionDetailVendorModel(
      uuid: entity.uuid,
      shopName: entity.shopName,
    );
  }
}


// ============================================================
// BID FEE
// ============================================================

class AuctionBidFeeModel {
  final bool applies;
  final double percent;
  final String source;

  AuctionBidFeeModel({
    required this.applies,
    required this.percent,
    required this.source,
  });

  factory AuctionBidFeeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuctionBidFeeModel(
      applies: json['applies'] ?? false,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      source: json['source']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "applies": applies,
      "percent": percent,
      "source": source,
    };
  }

  AuctionBidFeeEntity toEntity() {
    return AuctionBidFeeEntity(
      applies: applies,
      percent: percent,
      source: source,
    );
  }

  factory AuctionBidFeeModel.fromEntity(
    AuctionBidFeeEntity entity,
  ) {
    return AuctionBidFeeModel(
      applies: entity.applies,
      percent: entity.percent,
      source: entity.source,
    );
  }
}


// ============================================================
// EXTENSION
// ============================================================

class AuctionExtensionModel {
  final bool enabled;
  final int windowSeconds;
  final int durationSeconds;
  final int timesExtended;
  final String? originalEndAt;

  AuctionExtensionModel({
    required this.enabled,
    required this.windowSeconds,
    required this.durationSeconds,
    required this.timesExtended,
    this.originalEndAt,
  });

  factory AuctionExtensionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuctionExtensionModel(
      enabled: json['enabled'] ?? false,
      windowSeconds: json['windowSeconds'] ?? 0,
      durationSeconds: json['durationSeconds'] ?? 0,
      timesExtended: json['timesExtended'] ?? 0,
      originalEndAt: json['originalEndAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "enabled": enabled,
      "windowSeconds": windowSeconds,
      "durationSeconds": durationSeconds,
      "timesExtended": timesExtended,
      "originalEndAt": originalEndAt,
    };
  }

  AuctionExtensionEntity toEntity() {
    return AuctionExtensionEntity(
      enabled: enabled,
      windowSeconds: windowSeconds,
      durationSeconds: durationSeconds,
      timesExtended: timesExtended,
      originalEndAt: originalEndAt,
    );
  }

  factory AuctionExtensionModel.fromEntity(
    AuctionExtensionEntity entity,
  ) {
    return AuctionExtensionModel(
      enabled: entity.enabled,
      windowSeconds: entity.windowSeconds,
      durationSeconds: entity.durationSeconds,
      timesExtended: entity.timesExtended,
      originalEndAt: entity.originalEndAt,
    );
  }
}


// ============================================================
// VIEWER
// ============================================================

class AuctionDetailViewerModel {
  final bool isEligible;
  final String? ineligibleReason;
  final bool hasBid;
  final bool isHighestBidder;
  final String? highestUserBid;
  final bool isWinner;
  final String? allotmentUuid;
  final String? paymentDueAt;

  AuctionDetailViewerModel({
    required this.isEligible,
    this.ineligibleReason,
    required this.hasBid,
    required this.isHighestBidder,
    this.highestUserBid,
    required this.isWinner,
    this.allotmentUuid,
    this.paymentDueAt,
  });

  factory AuctionDetailViewerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuctionDetailViewerModel(
      isEligible: json['isEligible'] ?? false,
      ineligibleReason: json['ineligibleReason']?.toString(),
      hasBid: json['hasBid'] ?? false,
      isHighestBidder: json['isHighestBidder'] ?? false,
      highestUserBid: json['highestUserBid']?.toString(),
      isWinner: json['isWinner'] ?? false,
      allotmentUuid: json['allotmentUuid']?.toString(),
      paymentDueAt: json['paymentDueAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "isEligible": isEligible,
      "ineligibleReason": ineligibleReason,
      "hasBid": hasBid,
      "isHighestBidder": isHighestBidder,
      "highestUserBid": highestUserBid,
      "isWinner": isWinner,
      "allotmentUuid": allotmentUuid,
      "paymentDueAt": paymentDueAt,
    };
  }

  AuctionDetailViewerEntity toEntity() {
    return AuctionDetailViewerEntity(
      isEligible: isEligible,
      ineligibleReason: ineligibleReason,
      hasBid: hasBid,
      isHighestBidder: isHighestBidder,
      highestUserBid: highestUserBid,
      isWinner: isWinner,
      allotmentUuid: allotmentUuid,
      paymentDueAt: paymentDueAt,
    );
  }

  factory AuctionDetailViewerModel.fromEntity(
    AuctionDetailViewerEntity entity,
  ) {
    return AuctionDetailViewerModel(
      isEligible: entity.isEligible,
      ineligibleReason: entity.ineligibleReason,
      hasBid: entity.hasBid,
      isHighestBidder: entity.isHighestBidder,
      highestUserBid: entity.highestUserBid,
      isWinner: entity.isWinner,
      allotmentUuid: entity.allotmentUuid,
      paymentDueAt: entity.paymentDueAt,
    );
  }
}