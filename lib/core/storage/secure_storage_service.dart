// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:injectable/injectable.dart';
// import '../config/app_constants.dart';

// @singleton
// class SecureStorageService {
//   final FlutterSecureStorage _storage;
//   static const String emailKey = 'email';

//   const SecureStorageService({FlutterSecureStorage? storage})
//     : _storage = storage ?? const FlutterSecureStorage();

//   Future<void> saveAccessToken(String token) =>
//       _storage.write(key: AppConstants.accessTokenKey, value: token);

//   Future<void> saveRefreshToken(String token) =>
//       _storage.write(key: AppConstants.refreshTokenKey, value: token);

//   Future<void> saveUserId(String userId) =>
//       _storage.write(key: AppConstants.userIdKey, value: userId);

//   Future<String?> getAccessToken() =>
//       _storage.read(key: AppConstants.accessTokenKey);

//   Future<String?> getRefreshToken() =>
//       _storage.read(key: AppConstants.refreshTokenKey);

//   Future<String?> getUserId() => _storage.read(key: AppConstants.userIdKey);

//   Future<bool> hasAccessToken() async =>
//       (await _storage.read(key: AppConstants.accessTokenKey)) != null;

//   Future<void> clearAll() => _storage.deleteAll();

//   Future<void> saveEmail(String email) async {
//     await _storage.write(key: emailKey, value: email);
//   }

//   Future<String?> getEmail() async {
//     return await _storage.read(key: emailKey);
//   }

//   Future<void> deleteEmail() async {
//     await _storage.delete(key: emailKey);
//   }

//   Future<void> clear() async {
//     await _storage.deleteAll();
//   }
// }


  //FIXED FINDING CODE
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../config/app_constants.dart';

@singleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String emailKey = 'email';

  const SecureStorageService({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  // ─────────────────────────────────────────────────────────────
  // Access Token
  // ─────────────────────────────────────────────────────────────

  Future<void> saveAccessToken(String token) {
    return _storage.write(
      key: AppConstants.accessTokenKey,
      value: token,
    );
  }

  Future<String?> getAccessToken() {
    return _storage.read(
      key: AppConstants.accessTokenKey,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Refresh Token
  // ─────────────────────────────────────────────────────────────

  Future<void> saveRefreshToken(String token) {
    return _storage.write(
      key: AppConstants.refreshTokenKey,
      value: token,
    );
  }

  Future<String?> getRefreshToken() {
    return _storage.read(
      key: AppConstants.refreshTokenKey,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // User ID
  // ─────────────────────────────────────────────────────────────

  Future<void> saveUserId(String userId) {
    return _storage.write(
      key: AppConstants.userIdKey,
      value: userId,
    );
  }

  Future<String?> getUserId() {
    return _storage.read(
      key: AppConstants.userIdKey,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Token Check
  // ─────────────────────────────────────────────────────────────

  Future<bool> hasAccessToken() async {
    final accessToken = await _storage.read(
      key: AppConstants.accessTokenKey,
    );

    return accessToken != null && accessToken.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────
  // Generic Secure Storage
  // ─────────────────────────────────────────────────────────────
  //
  // Used for sensitive cached data such as UserModel JSON.
  // ─────────────────────────────────────────────────────────────

  Future<void> write({
    required String key,
    required String value,
  }) {
    return _storage.write(
      key: key,
      value: value,
    );
  }

  Future<String?> read({
    required String key,
  }) {
    return _storage.read(
      key: key,
    );
  }

  Future<void> delete({
    required String key,
  }) {
    return _storage.delete(
      key: key,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Email
  // ─────────────────────────────────────────────────────────────

  Future<void> saveEmail(String email) {
    return _storage.write(
      key: emailKey,
      value: email,
    );
  }

  Future<String?> getEmail() {
    return _storage.read(
      key: emailKey,
    );
  }

  Future<void> deleteEmail() {
    return _storage.delete(
      key: emailKey,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Clear Storage
  // ─────────────────────────────────────────────────────────────

  Future<void> clearAll() {
    return _storage.deleteAll();
  }

  Future<void> clear() {
    return _storage.deleteAll();
  }
}