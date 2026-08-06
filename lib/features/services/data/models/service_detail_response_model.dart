import 'package:json_annotation/json_annotation.dart';
import 'service_detail_model.dart';

part 'service_detail_response_model.g.dart';

@JsonSerializable()
class ServiceDetailResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final ServiceDetailDataWrapper data;
  final String timestamp;

  ServiceDetailResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory ServiceDetailResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceDetailResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceDetailResponseModelToJson(this);
}

@JsonSerializable()
class ServiceDetailDataWrapper {
  final String message;
  final ServiceDetailModel data;

  ServiceDetailDataWrapper({
    required this.message,
    required this.data,
  });

  factory ServiceDetailDataWrapper.fromJson(Map<String, dynamic> json) =>
      _$ServiceDetailDataWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceDetailDataWrapperToJson(this);
}
