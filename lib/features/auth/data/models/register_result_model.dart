import 'user_model.dart';

class RegisterResultModel {
  final String accessToken;
  final UserModel user;

  const RegisterResultModel({required this.accessToken, required this.user});

  factory RegisterResultModel.fromVendorJson(
    Map<String, dynamic> json, {
    required String firstName,
    required String lastName,
  }) {
    final vendor = json['vendor'] as Map<String, dynamic>;
    final bingoldData = json['bingold']['data'] as Map<String, dynamic>;
    return RegisterResultModel(
      accessToken: json['accessToken'] as String,
      user: UserModel(
        id: vendor['uuid'] as String,
        email: bingoldData['email'] as String,
        name: '$firstName $lastName'.trim(),
        role: 'vendor',
        kycStatus: vendor['kycStatus'] as String,
      ),
    );
  }
}
