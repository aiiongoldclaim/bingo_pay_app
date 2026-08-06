// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailabilityResponseModel _$AvailabilityResponseModelFromJson(
  Map<String, dynamic> json,
) => AvailabilityResponseModel(
  success: json['success'] as bool,
  statusCode: (json['statusCode'] as num).toInt(),
  message: json['message'] as String,
  data: AvailabilityDataModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AvailabilityResponseModelToJson(
  AvailabilityResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

AvailabilityDataModel _$AvailabilityDataModelFromJson(
  Map<String, dynamic> json,
) => AvailabilityDataModel(
  message: json['message'] as String,
  data: AvailabilityModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AvailabilityDataModelToJson(
  AvailabilityDataModel instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};

AvailabilityModel _$AvailabilityModelFromJson(Map<String, dynamic> json) =>
    AvailabilityModel(
      schedulingModel: json['schedulingModel'] as String,
      leadTimeMinutes: (json['leadTimeMinutes'] as num).toInt(),
      days: (json['days'] as List<dynamic>)
          .map((e) => DayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AvailabilityModelToJson(AvailabilityModel instance) =>
    <String, dynamic>{
      'schedulingModel': instance.schedulingModel,
      'leadTimeMinutes': instance.leadTimeMinutes,
      'days': instance.days,
    };

DayModel _$DayModelFromJson(Map<String, dynamic> json) => DayModel(
  date: json['date'] as String,
  slots: (json['slots'] as List<dynamic>)
      .map((e) => SlotModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DayModelToJson(DayModel instance) => <String, dynamic>{
  'date': instance.date,
  'slots': instance.slots,
};

SlotModel _$SlotModelFromJson(Map<String, dynamic> json) => SlotModel(
  uuid: json['uuid'] as String,
  startsAt: json['startsAt'] as String,
  endsAt: json['endsAt'] as String,
  remaining: (json['remaining'] as num).toInt(),
  offering: OfferingRefModel.fromJson(json['offering'] as Map<String, dynamic>),
  staff: json['staff'] as String?,
  resource: json['resource'] as String?,
);

Map<String, dynamic> _$SlotModelToJson(SlotModel instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'startsAt': instance.startsAt,
  'endsAt': instance.endsAt,
  'remaining': instance.remaining,
  'offering': instance.offering,
  'staff': instance.staff,
  'resource': instance.resource,
};

OfferingRefModel _$OfferingRefModelFromJson(Map<String, dynamic> json) =>
    OfferingRefModel(
      uuid: json['uuid'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$OfferingRefModelToJson(OfferingRefModel instance) =>
    <String, dynamic>{'uuid': instance.uuid, 'code': instance.code};
