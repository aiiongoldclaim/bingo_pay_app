import '../../domain/entities/my_bids_entity.dart';

class MyBidsModel {
  final List<MyBidItemModel> items;
  final int total;
  final MyBidsSummaryModel summary;

  MyBidsModel({
    required this.items,
    required this.total,
    required this.summary,
  });

  // ============================================================
  // JSON → MODEL
  // ============================================================

  factory MyBidsModel.fromJson(Map<String, dynamic> json) {
    return MyBidsModel(
      items: (json['items'] as List?)
              ?.map(
                (item) => MyBidItemModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      total: json['total'] ?? 0,
      summary: MyBidsSummaryModel.fromJson(
        json['summary'] ?? {},
      ),
    );
  }

  // ============================================================
  // MODEL → JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'summary': summary.toJson(),
    };
  }

  // ============================================================
  // MODEL → ENTITY
  // ============================================================

  MyBidsEntity toEntity() {
    return MyBidsEntity(
      items: items.map((e) => e.toEntity()).toList(),
      total: total,
      summary: summary.toEntity(),
    );
  }

  // ============================================================
  // ENTITY → MODEL
  // ============================================================

  factory MyBidsModel.fromEntity(MyBidsEntity entity) {
    return MyBidsModel(
      items: entity.items
          .map(
            (e) => MyBidItemModel.fromEntity(e),
          )
          .toList(),
      total: entity.total,
      summary: MyBidsSummaryModel.fromEntity(
        entity.summary,
      ),
    );
  }
}

// ============================================================
// MY BID ITEM MODEL
// ============================================================

class MyBidItemModel {
  final String uuid;
  final String number;
  final String title;
  final String? slug;
  final List<String>? images;
  final String? itemName;

  final String status;
  final String listingLevel;

  final MyBidCategoryModel? category;
  final MyBidVendorModel? vendor;

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

  final MyBidAllotmentModel? allotment;

  MyBidItemModel({
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

  // ============================================================
  // JSON → MODEL
  // ============================================================

  factory MyBidItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MyBidItemModel(
      uuid: json['uuid']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),

      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,

      itemName: json['itemName']?.toString(),

      status: json['status']?.toString() ?? '',
      listingLevel:
          json['listingLevel']?.toString() ?? '',

      category: json['category'] != null
          ? MyBidCategoryModel.fromJson(
              json['category'],
            )
          : null,

      vendor: json['vendor'] != null
          ? MyBidVendorModel.fromJson(
              json['vendor'],
            )
          : null,

      startingPrice:
          json['startingPrice']?.toString() ?? '',

      currentBid:
          json['currentBid']?.toString(),

      minimumNextBid:
          json['minimumNextBid']?.toString() ?? '',

      bidIncrement:
          json['bidIncrement']?.toString() ?? '',

      finalBid:
          json['finalBid']?.toString(),

      bidCount: json['bidCount'] ?? 0,

      startAt:
          json['startAt']?.toString() ?? '',

      endAt:
          json['endAt']?.toString() ?? '',

      secondsRemaining:
          json['secondsRemaining'],

      secondsUntilStart:
          json['secondsUntilStart'],

      badge:
          json['badge']?.toString() ?? '',

      currency:
          json['currency']?.toString() ?? '',

      myHighestBid:
          json['myHighestBid']?.toString(),

      myBidCount:
          json['myBidCount'] ?? 0,

      myLastBidAt:
          json['myLastBidAt']?.toString(),

      myBidFeesPaid:
          json['myBidFeesPaid']?.toString(),

      myBidFeeCount:
          json['myBidFeeCount'] ?? 0,

      myStatus:
          json['myStatus']?.toString() ?? '',

      allotment: json['allotment'] != null
          ? MyBidAllotmentModel.fromJson(
              json['allotment'],
            )
          : null,
    );
  }

  // ============================================================
  // MODEL → JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'number': number,
      'title': title,
      'slug': slug,
      'images': images,
      'itemName': itemName,
      'status': status,
      'listingLevel': listingLevel,
      'category': category?.toJson(),
      'vendor': vendor?.toJson(),
      'startingPrice': startingPrice,
      'currentBid': currentBid,
      'minimumNextBid': minimumNextBid,
      'bidIncrement': bidIncrement,
      'finalBid': finalBid,
      'bidCount': bidCount,
      'startAt': startAt,
      'endAt': endAt,
      'secondsRemaining': secondsRemaining,
      'secondsUntilStart': secondsUntilStart,
      'badge': badge,
      'currency': currency,
      'myHighestBid': myHighestBid,
      'myBidCount': myBidCount,
      'myLastBidAt': myLastBidAt,
      'myBidFeesPaid': myBidFeesPaid,
      'myBidFeeCount': myBidFeeCount,
      'myStatus': myStatus,
      'allotment': allotment?.toJson(),
    };
  }

  // ============================================================
  // MODEL → ENTITY
  // ============================================================

  MyBidItemEntity toEntity() {
    return MyBidItemEntity(
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
      currency: currency,
      myHighestBid: myHighestBid,
      myBidCount: myBidCount,
      myLastBidAt: myLastBidAt,
      myBidFeesPaid: myBidFeesPaid,
      myBidFeeCount: myBidFeeCount,
      myStatus: myStatus,
      allotment: allotment?.toEntity(),
    );
  }

  // ============================================================
  // ENTITY → MODEL
  // ============================================================

  factory MyBidItemModel.fromEntity(
    MyBidItemEntity entity,
  ) {
    return MyBidItemModel(
      uuid: entity.uuid,
      number: entity.number,
      title: entity.title,
      slug: entity.slug,
      images: entity.images,
      itemName: entity.itemName,
      status: entity.status,
      listingLevel: entity.listingLevel,

      category: entity.category != null
          ? MyBidCategoryModel.fromEntity(
              entity.category!,
            )
          : null,

      vendor: entity.vendor != null
          ? MyBidVendorModel.fromEntity(
              entity.vendor!,
            )
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
      currency: entity.currency,
      myHighestBid: entity.myHighestBid,
      myBidCount: entity.myBidCount,
      myLastBidAt: entity.myLastBidAt,
      myBidFeesPaid: entity.myBidFeesPaid,
      myBidFeeCount: entity.myBidFeeCount,
      myStatus: entity.myStatus,

      allotment: entity.allotment != null
          ? MyBidAllotmentModel.fromEntity(
              entity.allotment!,
            )
          : null,
    );
  }
}

// ============================================================
// CATEGORY MODEL
// ============================================================

class MyBidCategoryModel {
  final String uuid;
  final String name;
  final String slug;

  MyBidCategoryModel({
    required this.uuid,
    required this.name,
    required this.slug,
  });

  factory MyBidCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MyBidCategoryModel(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'slug': slug,
    };
  }

  MyBidCategoryEntity toEntity() {
    return MyBidCategoryEntity(
      uuid: uuid,
      name: name,
      slug: slug,
    );
  }

  factory MyBidCategoryModel.fromEntity(
    MyBidCategoryEntity entity,
  ) {
    return MyBidCategoryModel(
      uuid: entity.uuid,
      name: entity.name,
      slug: entity.slug,
    );
  }
}

// ============================================================
// VENDOR MODEL
// ============================================================

class MyBidVendorModel {
  final String uuid;
  final String shopName;

  MyBidVendorModel({
    required this.uuid,
    required this.shopName,
  });

  factory MyBidVendorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MyBidVendorModel(
      uuid: json['uuid']?.toString() ?? '',
      shopName:
          json['shopName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'shopName': shopName,
    };
  }

  MyBidVendorEntity toEntity() {
    return MyBidVendorEntity(
      uuid: uuid,
      shopName: shopName,
    );
  }

  factory MyBidVendorModel.fromEntity(
    MyBidVendorEntity entity,
  ) {
    return MyBidVendorModel(
      uuid: entity.uuid,
      shopName: entity.shopName,
    );
  }
}

// ============================================================
// ALLOTMENT MODEL
// ============================================================

class MyBidAllotmentModel {
  final String uuid;
  final String status;
  final String amount;
  final String paymentDueAt;
  final int rank;
  final bool isOverdue;

  MyBidAllotmentModel({
    required this.uuid,
    required this.status,
    required this.amount,
    required this.paymentDueAt,
    required this.rank,
    required this.isOverdue,
  });

  factory MyBidAllotmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MyBidAllotmentModel(
      uuid: json['uuid']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      paymentDueAt:
          json['paymentDueAt']?.toString() ?? '',
      rank: json['rank'] ?? 0,
      isOverdue:
          json['isOverdue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'status': status,
      'amount': amount,
      'paymentDueAt': paymentDueAt,
      'rank': rank,
      'isOverdue': isOverdue,
    };
  }

  MyBidAllotmentEntity toEntity() {
    return MyBidAllotmentEntity(
      uuid: uuid,
      status: status,
      amount: amount,
      paymentDueAt: paymentDueAt,
      rank: rank,
      isOverdue: isOverdue,
    );
  }

  factory MyBidAllotmentModel.fromEntity(
    MyBidAllotmentEntity entity,
  ) {
    return MyBidAllotmentModel(
      uuid: entity.uuid,
      status: entity.status,
      amount: entity.amount,
      paymentDueAt: entity.paymentDueAt,
      rank: entity.rank,
      isOverdue: entity.isOverdue,
    );
  }
}

// ============================================================
// SUMMARY MODEL
// ============================================================

class MyBidsSummaryModel {
  final int leading;
  final int outbid;
  final int won;
  final int paymentDue;
  final int lost;

  MyBidsSummaryModel({
    required this.leading,
    required this.outbid,
    required this.won,
    required this.paymentDue,
    required this.lost,
  });

  factory MyBidsSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MyBidsSummaryModel(
      leading: json['leading'] ?? 0,
      outbid: json['outbid'] ?? 0,
      won: json['won'] ?? 0,
      paymentDue: json['paymentDue'] ?? 0,
      lost: json['lost'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leading': leading,
      'outbid': outbid,
      'won': won,
      'paymentDue': paymentDue,
      'lost': lost,
    };
  }

  MyBidsSummaryEntity toEntity() {
    return MyBidsSummaryEntity(
      leading: leading,
      outbid: outbid,
      won: won,
      paymentDue: paymentDue,
      lost: lost,
    );
  }

  factory MyBidsSummaryModel.fromEntity(
    MyBidsSummaryEntity entity,
  ) {
    return MyBidsSummaryModel(
      leading: entity.leading,
      outbid: entity.outbid,
      won: entity.won,
      paymentDue: entity.paymentDue,
      lost: entity.lost,
    );
  }
}