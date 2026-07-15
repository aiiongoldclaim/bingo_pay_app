import '../../domain/entities/user_existence_entity.dart';

class UserExistenceModel {
  final bool exists;
  final bool hasLocalProfile;
  final bool hasLocalPassword;
  final bool checked;
  final bool localEntry;
  final String? fullName;
  final String? phone;
  final String? avatar;

  const UserExistenceModel({
    required this.exists,
    required this.hasLocalProfile,
    required this.hasLocalPassword,
    required this.checked,
    required this.localEntry,
    this.fullName,
    this.phone,
    this.avatar,
  });

  factory UserExistenceModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    return UserExistenceModel(
      exists: json['exists'] as bool? ?? false,
      hasLocalProfile: json['hasLocalProfile'] as bool? ?? false,
      hasLocalPassword: json['hasLocalPassword'] as bool? ?? false,
      checked: json['checked'] as bool? ?? false,
      localEntry: json['localEntry'] as bool? ?? false,
      fullName: profile['fullName'] as String?,
      phone: profile['phone'] as String?,
      avatar: profile['avatar'] as String?,
    );
  }

  UserExistenceEntity toEntity() => UserExistenceEntity(
        exists: exists,
        hasLocalProfile: hasLocalProfile,
        hasLocalPassword: hasLocalPassword,
        checked: checked,
        localEntry: localEntry,
        fullName: fullName,
        phone: phone,
        avatar: avatar,
      );
}
