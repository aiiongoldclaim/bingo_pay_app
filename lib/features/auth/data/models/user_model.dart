import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.kycStatus,
    super.emailVerified = false,
    super.phoneVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Maps the `profile` object returned by the register/login API
  /// (snake_case fields) into a [UserModel].
  factory UserModel.fromProfileJson(Map<String, dynamic> profile) =>
      UserModel(
        id: profile['uuid'] as String,
        email: profile['email'] as String,
        name: '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'
            .trim(),
        kycStatus: profile['kyc_status'] as String? ?? 'not_required',
        emailVerified: profile['email_verified'] as bool? ?? false,
        phoneVerified: profile['phone_verified'] as bool? ?? false,
      );

  UserModel copyWith({
    String? kycStatus,
    bool? emailVerified,
    bool? phoneVerified,
  }) =>
      UserModel(
        id: id,
        email: email,
        name: name,
        kycStatus: kycStatus ?? this.kycStatus,
        emailVerified: emailVerified ?? this.emailVerified,
        phoneVerified: phoneVerified ?? this.phoneVerified,
      );
}
