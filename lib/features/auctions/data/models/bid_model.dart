import '../../domain/entities/bid_entity.dart';

class BidModel {
  final String uuid;
  final String amount;
  final int sequence;
  final String placedAt;
  final BidderModel? bidder;

  BidModel({
    required this.uuid,
    required this.amount,
    required this.sequence,
    required this.placedAt,
    this.bidder,
  });

  /// 🔁 JSON → Model
  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      uuid: json['uuid']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      sequence: json['sequence'] is int
          ? json['sequence']
          : int.tryParse(json['sequence']?.toString() ?? '') ?? 0,
      placedAt: json['placedAt']?.toString() ?? '',
      bidder: json['bidder'] != null
          ? BidderModel.fromJson(
              Map<String, dynamic>.from(json['bidder']),
            )
          : null,
    );
  }

  /// 🔁 Model → JSON
  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "amount": amount,
      "sequence": sequence,
      "placedAt": placedAt,
      "bidder": bidder?.toJson(),
    };
  }

  /// 🔁 Model → Entity
  BidEntity toEntity() {
    return BidEntity(
      uuid: uuid,
      amount: amount,
      sequence: sequence,
      placedAt: placedAt,
      bidder: bidder?.toEntity(),
    );
  }

  /// 🔁 Entity → Model
  factory BidModel.fromEntity(BidEntity entity) {
    return BidModel(
      uuid: entity.uuid,
      amount: entity.amount,
      sequence: entity.sequence,
      placedAt: entity.placedAt,
      bidder: entity.bidder != null
          ? BidderModel.fromEntity(entity.bidder!)
          : null,
    );
  }
}

class BidderModel {
  final String alias;
  final String maskedName;

  BidderModel({
    required this.alias,
    required this.maskedName,
  });

  /// 🔁 JSON → Model
  factory BidderModel.fromJson(Map<String, dynamic> json) {
    return BidderModel(
      alias: json['alias']?.toString() ?? '',
      maskedName: json['maskedName']?.toString() ?? '',
    );
  }

  /// 🔁 Model → JSON
  Map<String, dynamic> toJson() {
    return {
      "alias": alias,
      "maskedName": maskedName,
    };
  }

  /// 🔁 Model → Entity
  BidderEntity toEntity() {
    return BidderEntity(
      alias: alias,
      maskedName: maskedName,
    );
  }

  /// 🔁 Entity → Model
  factory BidderModel.fromEntity(BidderEntity entity) {
    return BidderModel(
      alias: entity.alias,
      maskedName: entity.maskedName,
    );
  }
}