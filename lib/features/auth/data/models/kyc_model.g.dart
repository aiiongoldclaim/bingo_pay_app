// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KycModel _$KycModelFromJson(Map<String, dynamic> json) => KycModel(
  status: json['status'] as String,
  rejectionReason: json['rejectionReason'] as String?,
);

Map<String, dynamic> _$KycModelToJson(KycModel instance) => <String, dynamic>{
  'status': instance.status,
  'rejectionReason': instance.rejectionReason,
};
