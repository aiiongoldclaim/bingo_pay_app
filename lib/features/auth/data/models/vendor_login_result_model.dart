import 'user_model.dart';

class VendorLoginResultModel {
  final String accessToken;
  final UserModel user;

  const VendorLoginResultModel({required this.accessToken, required this.user});

  factory VendorLoginResultModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map<String, dynamic>;
    final profile = json['bingoldProfile']['data'] as Map<String, dynamic>;
    final userDetail = profile['userDetail'] as Map<String, dynamic>;
    return VendorLoginResultModel(
      accessToken: json['accessToken'] as String,
      user: UserModel(
        id: vendor['uuid'] as String,
        email: profile['email'] as String,
        name: '${userDetail['firstName']} ${userDetail['lastName']}'.trim(),
        role: 'vendor',
        kycStatus: vendor['kycStatus'] as String,
        shopName: vendor['shopName'] as String?,
        merchantCode: vendor['merchantCode'] as String?,
        businessName: vendor['businessName'] as String?,
      ),
    );
  }
}
