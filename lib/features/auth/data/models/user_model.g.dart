// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  kycStatus: json['kycStatus'] as String,
  emailVerified: json['emailVerified'] as bool? ?? false,
  phoneVerified: json['phoneVerified'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'kycStatus': instance.kycStatus,
  'emailVerified': instance.emailVerified,
  'phoneVerified': instance.phoneVerified,
};
