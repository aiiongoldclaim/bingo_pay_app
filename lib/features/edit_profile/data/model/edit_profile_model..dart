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

  factory EditProfileModel.fromJson(Map<String, dynamic> json) =>
      EditProfileModel(
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        profileImageUrl: json['profileImageUrl'] as String?,
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