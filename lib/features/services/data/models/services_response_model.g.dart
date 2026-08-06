// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServicesResponseModel _$ServicesResponseModelFromJson(
  Map<String, dynamic> json,
) => ServicesResponseModel(
  success: json['success'] as bool,
  statusCode: (json['statusCode'] as num).toInt(),
  message: json['message'] as String,
  data: ServicesDataModel.fromJson(json['data'] as Map<String, dynamic>),
  timestamp: json['timestamp'] as String,
);

Map<String, dynamic> _$ServicesResponseModelToJson(
  ServicesResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
  'timestamp': instance.timestamp,
};

ServicesDataModel _$ServicesDataModelFromJson(Map<String, dynamic> json) =>
    ServicesDataModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: MetaModel.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ServicesDataModelToJson(ServicesDataModel instance) =>
    <String, dynamic>{'data': instance.data, 'meta': instance.meta};

MetaModel _$MetaModelFromJson(Map<String, dynamic> json) => MetaModel(
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$MetaModelToJson(MetaModel instance) => <String, dynamic>{
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'totalPages': instance.totalPages,
};
