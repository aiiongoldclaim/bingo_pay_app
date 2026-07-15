// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
  kycStatus: json['kycStatus'] as String,
  kybStatus: json['kybStatus'] as String? ?? 'none',
  shopName: json['shopName'] as String?,
  merchantCode: json['merchantCode'] as String?,
  businessName: json['businessName'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': instance.role,
  'kycStatus': instance.kycStatus,
  'kybStatus': instance.kybStatus,
  'shopName': instance.shopName,
  'merchantCode': instance.merchantCode,
  'businessName': instance.businessName,
};
