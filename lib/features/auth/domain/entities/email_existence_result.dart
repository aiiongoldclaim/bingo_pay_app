import 'package:equatable/equatable.dart';

class EmailExistenceResult extends Equatable {
  final bool exists;
  final bool hasLocalProfile;
  final bool localEntry;
  final bool hasLocalPassword;

  const EmailExistenceResult({
    required this.exists,
    required this.hasLocalProfile,
    required this.localEntry,
    required this.hasLocalPassword,
  });

  /// True when the email belongs to an existing BinGold account with a
  /// local profile and entry but no local password set — these users
  /// should be sent to SSO login instead of the normal register/login flow.
  bool get requiresSsoLogin =>
      exists && hasLocalProfile && localEntry && !hasLocalPassword;

  @override
  List<Object?> get props =>
      [exists, hasLocalProfile, localEntry, hasLocalPassword];
}
