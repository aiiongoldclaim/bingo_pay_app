import '../../../profile/domain/enities/profile_entity.dart';

class EditProfileModel {
  final String fullName;
  final String email; // read-only
  final String phoneNumber;
  final String? profileImageUrl;

  const EditProfileModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
  });

  EditProfileModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) => EditProfileModel(
    fullName: fullName ?? this.fullName,
    email: email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
  );

  /// Email is otherwise fixed by [copyWith] since it's read-only in the UI —
  /// this exists only to backfill it from a known-good source.
  EditProfileModel copyWithEmail(String newEmail) => EditProfileModel(
    fullName: fullName,
    email: newEmail,
    phoneNumber: phoneNumber,
    profileImageUrl: profileImageUrl,
  );

  factory EditProfileModel.fromJson(Map<String, dynamic> json) =>
      EditProfileModel(
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        profileImageUrl: json['profileImageUrl'] as String?,
      );

  /// Mirrors the same profile data the Profile screen (ProfileCubit) shows,
  /// so Edit Profile never disagrees with it on name/email.
  factory EditProfileModel.fromProfileEntity(ProfileEntity profile) =>
      EditProfileModel(
        fullName: profile.fullName,
        email: profile.email,
        phoneNumber: profile.phone,
        profileImageUrl: profile.profileImageUrl,
      );

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phoneNumber': phoneNumber,
  };

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
