// import 'dart:convert';
// import 'package:injectable/injectable.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../core/storage/secure_storage_service.dart';
// import '../models/user_model.dart';

// abstract interface class AuthLocalDataSource {
//   Future<void> saveTokens({
//     required String accessToken,
//     required String refreshToken,
//   });

//   Future<void> saveAccessToken(String accessToken);

//   Future<void> saveUser(UserModel user);

//   Future<UserModel?> getUser();

//   Future<void> clearAll();
// }

// @Injectable(as: AuthLocalDataSource)
// class AuthLocalDataSourceImpl implements AuthLocalDataSource {
//   final SecureStorageService _secureStorage;
//   final SharedPreferences _prefs;

//   AuthLocalDataSourceImpl(this._secureStorage, this._prefs);

//   static const _userKey = 'cached_user';

//   @override
//   Future<void> saveTokens({
//     required String accessToken,
//     required String refreshToken,
//   }) async {
//     await _secureStorage.saveAccessToken(accessToken);
//     await _secureStorage.saveRefreshToken(refreshToken);
//   }

//   @override
//   Future<void> saveAccessToken(String accessToken) async {
//     await _secureStorage.saveAccessToken(accessToken);
//   }

//   @override
//   Future<void> saveUser(UserModel user) async {
//     await _prefs.setString(_userKey, jsonEncode(user.toJson()));
//   }

//   @override
//   Future<UserModel?> getUser() async {
//     final hasToken = await _secureStorage.hasAccessToken();
//     if (!hasToken) return null;
//     final json = _prefs.getString(_userKey);
//     if (json == null) {
//       // User data is missing but token exists — clear stale token for consistency
//       await _secureStorage.clearAll();
//       return null;
//     }
//     return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
//   }

//   @override
//   Future<void> clearAll() async {
//     await _secureStorage.clearAll();
//     await _prefs.remove(_userKey);
//   }
// }

//FIXED FINDING CODE

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

  static const String _userKey = 'cached_user';

  AuthLocalDataSourceImpl(this._secureStorage, this._prefs);

  // ─────────────────────────────────────────────────────────────
  // Tokens
  // ─────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────
  // User
  // ─────────────────────────────────────────────────────────────

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());

    // Sensitive user data is stored in secure storage,
    // NOT SharedPreferences.
    await _secureStorage.write(key: _userKey, value: userJson);

    // Remove any legacy plaintext copy created by
    // previous versions of the application.
    await _prefs.remove(_userKey);
  }

  @override
  Future<UserModel?> getUser() async {
    final hasToken = await _secureStorage.hasAccessToken();

    if (!hasToken) {
      return null;
    }

    final json = await _secureStorage.read(key: _userKey);

    if (json == null || json.isEmpty) {
      // Token exists but cached user is missing.
      // Clear stale authentication state.
      await _secureStorage.clearAll();

      // Also remove legacy plaintext data, if present.
      await _prefs.remove(_userKey);

      return null;
    }

    try {
      final decoded = jsonDecode(json);

      if (decoded is! Map) {
        await _secureStorage.delete(key: _userKey);

        return null;
      }

      final userMap = Map<String, dynamic>.from(decoded);

      return UserModel.fromJson(userMap);
    } on FormatException {
      // Cached JSON is corrupted.
      await _secureStorage.delete(key: _userKey);

      return null;
    } on TypeError {
      // Cached JSON structure does not match UserModel.
      await _secureStorage.delete(key: _userKey);

      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Clear
  // ─────────────────────────────────────────────────────────────

  @override
  Future<void> clearAll() async {
    // Clears access token, refresh token, user ID,
    // cached user and other secure values.
    await _secureStorage.clearAll();

    // Remove legacy plaintext cached user from
    // SharedPreferences created by older app versions.
    await _prefs.remove(_userKey);
  }
}
