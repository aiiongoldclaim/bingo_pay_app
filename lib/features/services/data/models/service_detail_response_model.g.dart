// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_detail_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceDetailResponseModel _$ServiceDetailResponseModelFromJson(
  Map<String, dynamic> json,
) => ServiceDetailResponseModel(
  success: json['success'] as bool,
  statusCode: (json['statusCode'] as num).toInt(),
  message: json['message'] as String,
  data: ServiceDetailDataWrapper.fromJson(json['data'] as Map<String, dynamic>),
  timestamp: json['timestamp'] as String,
);

Map<String, dynamic> _$ServiceDetailResponseModelToJson(
  ServiceDetailResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
  'timestamp': instance.timestamp,
};

ServiceDetailDataWrapper _$ServiceDetailDataWrapperFromJson(
  Map<String, dynamic> json,
) => ServiceDetailDataWrapper(
  message: json['message'] as String,
  data: ServiceDetailModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ServiceDetailDataWrapperToJson(
  ServiceDetailDataWrapper instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};
