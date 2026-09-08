import 'profile_data_model.dart';

class ProfileResponseModel {
  final bool success;
  final String message;
  final ProfileModel profile;

  const ProfileResponseModel({
    required this.success,
    required this.message,
    required this.profile,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>? ?? const {};
    final inner = outer['data'] as Map<String, dynamic>? ?? outer;
    final bingold = inner['bingold'] as Map<String, dynamic>? ?? const {};
    final balances =
        (bingold['balances'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const [];
    final walletAddresses =
        bingold['walletAddresses'] as Map<String, dynamic>? ?? const {};
    return ProfileResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      profile: ProfileModel.fromJson(
        inner,
        wallet: balances,
        walletAddresses: walletAddresses,
        bingoldKycStatus: bingold['kycStatus'] as String?,
      ),
    );
  }
}
