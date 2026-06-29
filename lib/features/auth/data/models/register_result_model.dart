import 'user_model.dart';

class RegisterResultModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final Map<String, dynamic> vendorData;

  const RegisterResultModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.vendorData,
  });

  factory RegisterResultModel.fromVendorJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>;
    final roles = user['roles'] as List<dynamic>?;
    final role = (roles != null && roles.isNotEmpty) ? roles.first as String : 'vendor';
    final verificationStatus =
        (vendor['verificationStatus'] as String?)?.toLowerCase() ?? 'pending';
    return RegisterResultModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String? ?? '',
      user: UserModel(
        id: user['uuid'] as String,
        email: user['email'] as String,
        name: user['fullName'] as String,
        role: role,
        kycStatus: verificationStatus,
        shopName: vendor['shopName'] as String?,
        merchantCode: vendor['merchantCode'] as String?,
        businessName: vendor['businessName'] as String?,
      ),
      vendorData: vendor,
    );
  }
}
