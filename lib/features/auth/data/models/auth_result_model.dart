import 'user_model.dart';

/// Result of a login/register call against the real API, which returns a
/// single `token` plus a nested `profile` object (mapped via
/// [UserModel.fromProfileJson]) rather than a generic accessToken/
/// refreshToken/user shape.
class AuthResultModel {
  final String token;
  final UserModel user;

  const AuthResultModel({required this.token, required this.user});
}
