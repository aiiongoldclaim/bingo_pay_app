import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../config/app_constants.dart';

@singleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<void> saveUserId(String userId) =>
      _storage.write(key: AppConstants.userIdKey, value: userId);

  Future<void> saveBingoldUuid(String bingoldUuid) =>
      _storage.write(key: AppConstants.bingoldUuidKey, value: bingoldUuid);

  Future<void> saveVendorUuid(String vendorUuid) =>
      _storage.write(key: AppConstants.vendorUuidKey, value: vendorUuid);

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  Future<String?> getUserId() => _storage.read(key: AppConstants.userIdKey);
  Future<String?> getBingoldUuid() =>
      _storage.read(key: AppConstants.bingoldUuidKey);

  Future<String?> getVendorUuid() =>
      _storage.read(key: AppConstants.vendorUuidKey);

  Future<bool> hasAccessToken() async =>
      (await _storage.read(key: AppConstants.accessTokenKey)) != null;

  Future<void> clearAll() => _storage.deleteAll();
}
