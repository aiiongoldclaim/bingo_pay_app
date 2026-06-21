import 'user_model.dart';

class AuthResponseModel {
  final String? token;
  final UserModel user;

  const AuthResponseModel({
    this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String?,
      user: UserModel.fromProfileJson(json['profile'] as Map<String, dynamic>),
    );
  }
}
