import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> saveAccessToken(String accessToken);

  Future<void> saveUser(UserModel user);

  Future<UserModel?> getUser();

  Future<void> clearAll();
}

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _secureStorage;
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._secureStorage, this._prefs);

  static const _userKey = 'cached_user';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
  }

  @override
  Future<void> saveAccessToken(String accessToken) async {
    await _secureStorage.saveAccessToken(accessToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final hasToken = await _secureStorage.hasAccessToken();
    if (!hasToken) return null;
    final json = _prefs.getString(_userKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> clearAll() async {
    await _secureStorage.clearAll();
    await _prefs.remove(_userKey);
  }
}
