import '../../domain/entities/auction_entity.dart';

class AuctionModel {
  final String uuid;
  final String number;
  final String title;
  final String? slug;
  final List<String>? images;
  final String? itemName;
  final String status;
  final String listingLevel;

  final AuctionCategoryModel? category;
  final AuctionVendorModel? vendor;

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
  final AuctionViewerModel? viewer;

  AuctionModel({
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

  /// 🔁 JSON → Model
  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    return AuctionModel(
      uuid: json['uuid']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug'],

      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,

      itemName: json['itemName'],

      status: json['status']?.toString() ?? '',
      listingLevel: json['listingLevel']?.toString() ?? '',

      category: json['category'] != null
          ? AuctionCategoryModel.fromJson(json['category'])
          : null,

      vendor: json['vendor'] != null
          ? AuctionVendorModel.fromJson(json['vendor'])
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

      viewer: json['viewer'] != null
          ? AuctionViewerModel.fromJson(json['viewer'])
          : null,
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
      "viewer": viewer?.toJson(),
    };
  }

  /// 🔁 Model → Entity
  AuctionEntity toEntity() {
    return AuctionEntity(
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
      viewer: viewer?.toEntity(),
    );
  }

  /// 🔁 Entity → Model
  factory AuctionModel.fromEntity(AuctionEntity entity) {
    return AuctionModel(
      uuid: entity.uuid,
      number: entity.number,
      title: entity.title,
      slug: entity.slug,
      images: entity.images,
      itemName: entity.itemName,
      status: entity.status,
      listingLevel: entity.listingLevel,
      category: entity.category != null
          ? AuctionCategoryModel.fromEntity(entity.category!)
          : null,
      vendor: entity.vendor != null
          ? AuctionVendorModel.fromEntity(entity.vendor!)
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
      viewer: entity.viewer != null
          ? AuctionViewerModel.fromEntity(entity.viewer!)
          : null,
    );
  }
}

class AuctionCategoryModel {
  final String uuid;
  final String name;
  final String slug;

  AuctionCategoryModel({
    required this.uuid,
    required this.name,
    required this.slug,
  });

  factory AuctionCategoryModel.fromJson(Map<String, dynamic> json) {
    return AuctionCategoryModel(
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

  AuctionCategoryEntity toEntity() {
    return AuctionCategoryEntity(
      uuid: uuid,
      name: name,
      slug: slug,
    );
  }

  factory AuctionCategoryModel.fromEntity(AuctionCategoryEntity entity) {
    return AuctionCategoryModel(
      uuid: entity.uuid,
      name: entity.name,
      slug: entity.slug,
    );
  }
}

class AuctionVendorModel {
  final String uuid;
  final String shopName;

  AuctionVendorModel({
    required this.uuid,
    required this.shopName,
  });

  factory AuctionVendorModel.fromJson(Map<String, dynamic> json) {
    return AuctionVendorModel(
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

  AuctionVendorEntity toEntity() {
    return AuctionVendorEntity(
      uuid: uuid,
      shopName: shopName,
    );
  }

  factory AuctionVendorModel.fromEntity(AuctionVendorEntity entity) {
    return AuctionVendorModel(
      uuid: entity.uuid,
      shopName: entity.shopName,
    );
  }
}

class AuctionViewerModel {
  final bool hasBid;
  final bool isHighestBidder;
  final String? highestUserBid;

  AuctionViewerModel({
    required this.hasBid,
    required this.isHighestBidder,
    this.highestUserBid,
  });

  factory AuctionViewerModel.fromJson(Map<String, dynamic> json) {
    return AuctionViewerModel(
      hasBid: json['hasBid'] ?? false,
      isHighestBidder: json['isHighestBidder'] ?? false,
      highestUserBid: json['highestUserBid']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "hasBid": hasBid,
      "isHighestBidder": isHighestBidder,
      "highestUserBid": highestUserBid,
    };
  }

  AuctionViewerEntity toEntity() {
    return AuctionViewerEntity(
      hasBid: hasBid,
      isHighestBidder: isHighestBidder,
      highestUserBid: highestUserBid,
    );
  }

  factory AuctionViewerModel.fromEntity(AuctionViewerEntity entity) {
    return AuctionViewerModel(
      hasBid: entity.hasBid,
      isHighestBidder: entity.isHighestBidder,
      highestUserBid: entity.highestUserBid,
    );
  }
}