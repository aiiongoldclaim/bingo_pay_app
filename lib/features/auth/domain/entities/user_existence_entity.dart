class UserExistenceEntity {
  final bool exists;
  final bool hasLocalProfile;
  final bool hasLocalPassword;
  final bool checked;
  final bool localEntry;
  final String? fullName;
  final String? phone;
  final String? avatar;

  const UserExistenceEntity({
    required this.exists,
    required this.hasLocalProfile,
    required this.hasLocalPassword,
    required this.checked,
    required this.localEntry,
    this.fullName,
    this.phone,
    this.avatar,
  });
}
