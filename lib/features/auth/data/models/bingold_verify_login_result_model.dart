import '../../domain/entities/user_entity.dart';
import 'user_model.dart';

class BingoldVerifyLoginResultModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final bool requiresPasswordSetup;

  const BingoldVerifyLoginResultModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.requiresPasswordSetup,
  });

  factory BingoldVerifyLoginResultModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final tokens = json['tokens'] as Map<String, dynamic>;
    final roles = user['roles'] as List<dynamic>?;
    var role = 'customer';
    if (roles != null && roles.isNotEmpty) {
      final roleObj =
          (roles.first as Map<String, dynamic>)['role'] as Map<String, dynamic>?;
      role = roleObj?['slug'] as String? ?? role;
    }
    // NOTE: this endpoint's `vendor` object hasn't been confirmed against a
    // real response — falls back to 'none' if absent. Verify against a live
    // BinGold verify-login response and adjust if the field lives elsewhere.
    final vendor = json['vendor'] as Map<String, dynamic>?;
    final kybStatus = kybStatusToString(
      kybStatusFromString(vendor?['kybStatus'] as String?),
    );
    return BingoldVerifyLoginResultModel(
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String? ?? '',
      user: UserModel(
        id: user['uuid'] as String,
        email: user['email'] as String,
        name: user['fullName'] as String,
        role: role,
        kycStatus: (user['kycStatus'] as String?)?.toLowerCase() ?? 'none',
        kybStatus: kybStatus,
      ),
      requiresPasswordSetup: json['requiresPasswordSetup'] as bool? ?? false,
    );
  }
}
