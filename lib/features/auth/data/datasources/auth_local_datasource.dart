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

  Future<void> saveUser(UserModel user);

  Future<UserModel?> getUser();

  Future<void> saveVendorData(Map<String, dynamic> vendorData);

  Future<Map<String, dynamic>?> getVendorData();

  Future<void> clearAll();
}

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _secureStorage;
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._secureStorage, this._prefs);

  static const _userKey = 'cached_user';
  static const _vendorKey = 'cached_vendor';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _secureStorage.saveUserId(user.id);
    await _secureStorage.saveBingoldUuid(user.id);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final hasToken = await _secureStorage.hasAccessToken();
    if (!hasToken) return null;
    final json = _prefs.getString(_userKey);
    if (json == null) return null;
    final user = UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    // Backfills bingoldUuid for sessions cached before this field existed,
    // so a restored session (no fresh saveUser call) can still call
    // getProfile() instead of crashing on a null bingoldUuid.
    if (await _secureStorage.getBingoldUuid() == null) {
      await _secureStorage.saveBingoldUuid(user.id);
    }
    return user;
  }

  @override
  Future<void> saveVendorData(Map<String, dynamic> vendorData) async {
    await _prefs.setString(_vendorKey, jsonEncode(vendorData));
    final vendorUuid = vendorData['uuid'] as String?;
    if (vendorUuid != null) {
      await _secureStorage.saveVendorUuid(vendorUuid);
    }
  }

  @override
  Future<Map<String, dynamic>?> getVendorData() async {
    final json = _prefs.getString(_vendorKey);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  @override
  Future<void> clearAll() async {
    await _secureStorage.clearAll();
    await _prefs.remove(_userKey);
    await _prefs.remove(_vendorKey);
  }
}
