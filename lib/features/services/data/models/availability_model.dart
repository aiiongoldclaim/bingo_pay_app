import 'package:json_annotation/json_annotation.dart';

part 'availability_model.g.dart';

@JsonSerializable()
class AvailabilityResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final AvailabilityDataModel data;

  AvailabilityResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory AvailabilityResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityResponseModelToJson(this);
}

@JsonSerializable()
class AvailabilityDataModel {
  final String message;
  final AvailabilityModel data;

  AvailabilityDataModel({
    required this.message,
    required this.data,
  });

  factory AvailabilityDataModel.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityDataModelToJson(this);
}

@JsonSerializable()
class AvailabilityModel {
  final String schedulingModel;
  final int leadTimeMinutes;
  final List<DayModel> days;

  AvailabilityModel({
    required this.schedulingModel,
    required this.leadTimeMinutes,
    required this.days,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityModelToJson(this);
}

@JsonSerializable()
class DayModel {
  final String date;
  final List<SlotModel> slots;

  DayModel({
    required this.date,
    required this.slots,
  });

  factory DayModel.fromJson(Map<String, dynamic> json) =>
      _$DayModelFromJson(json);

  Map<String, dynamic> toJson() => _$DayModelToJson(this);
}

@JsonSerializable()
class SlotModel {
  final String uuid;
  final String startsAt;
  final String endsAt;
  final int remaining;
  final OfferingRefModel offering;
  final String? staff;
  final String? resource;

  SlotModel({
    required this.uuid,
    required this.startsAt,
    required this.endsAt,
    required this.remaining,
    required this.offering,
    this.staff,
    this.resource,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) =>
      _$SlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$SlotModelToJson(this);
}

@JsonSerializable()
class OfferingRefModel {
  final String uuid;
  final String code;

  OfferingRefModel({
    required this.uuid,
    required this.code,
  });

  factory OfferingRefModel.fromJson(Map<String, dynamic> json) =>
      _$OfferingRefModelFromJson(json);

  Map<String, dynamic> toJson() => _$OfferingRefModelToJson(this);
}
