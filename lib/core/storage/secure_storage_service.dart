import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../config/app_constants.dart';

@singleton
class SecureStorageService {
  final FlutterSecureStorage _storage;
  static const String emailKey = 'email';

  const SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<void> saveUserId(String userId) =>
      _storage.write(key: AppConstants.userIdKey, value: userId);

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  Future<String?> getUserId() => _storage.read(key: AppConstants.userIdKey);

  Future<bool> hasAccessToken() async =>
      (await _storage.read(key: AppConstants.accessTokenKey)) != null;

  Future<void> clearAll() => _storage.deleteAll();

  Future<void> saveEmail(String email) async {
    await _storage.write(key: emailKey, value: email);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: emailKey);
  }

  Future<void> deleteEmail() async {
    await _storage.delete(key: emailKey);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
