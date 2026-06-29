import 'user_model.dart';

class AuthResultModel {
  final String token;
  final String refreshToken;
  final UserModel user;

  const AuthResultModel({
    required this.token,
    required this.refreshToken,
    required this.user,
  });
}
