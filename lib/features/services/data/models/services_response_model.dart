import 'package:json_annotation/json_annotation.dart';
import 'service_model.dart';

part 'services_response_model.g.dart';

@JsonSerializable()
class ServicesResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final ServicesDataModel data;
  final String timestamp;

  ServicesResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory ServicesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ServicesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServicesResponseModelToJson(this);
}

@JsonSerializable()
class ServicesDataModel {
  final List<ServiceModel> data;
  final MetaModel meta;

  ServicesDataModel({
    required this.data,
    required this.meta,
  });

  factory ServicesDataModel.fromJson(Map<String, dynamic> json) =>
      _$ServicesDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServicesDataModelToJson(this);
}

@JsonSerializable()
class MetaModel {
  final int total;
  final int page;
  final int limit;
  @JsonKey(name: 'totalPages')
  final int totalPages;

  MetaModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) =>
      _$MetaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetaModelToJson(this);
}
