import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';

@singleton
class PreferencesService {
  final SharedPreferences _prefs;

  const PreferencesService(this._prefs);

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.themeModeKey, mode);

  String? getThemeMode() => _prefs.getString(AppConstants.themeModeKey);

  Future<void> setOnboardingSeen() =>
      _prefs.setBool(AppConstants.onboardingSeenKey, true);

  bool isOnboardingSeen() =>
      _prefs.getBool(AppConstants.onboardingSeenKey) ?? false;

  Future<void> setLocale(String locale) =>
      _prefs.setString(AppConstants.localeKey, locale);

  String? getLocale() => _prefs.getString(AppConstants.localeKey);

  List<String> getRecentSearches() =>
      _prefs.getStringList(AppConstants.recentSearchesKey) ?? const [];

  Future<void> setRecentSearches(List<String> searches) =>
      _prefs.setStringList(AppConstants.recentSearchesKey, searches);

  Future<void> clearRecentSearches() =>
      _prefs.remove(AppConstants.recentSearchesKey);

  bool isPushNotificationsEnabled() =>
      _prefs.getBool(AppConstants.pushNotificationsEnabledKey) ?? true;

  Future<void> setPushNotificationsEnabled(bool enabled) =>
      _prefs.setBool(AppConstants.pushNotificationsEnabledKey, enabled);

  List<String>? getNotifiedNotificationIds() =>
      _prefs.getStringList(AppConstants.notifiedNotificationIdsKey);

  Future<void> setNotifiedNotificationIds(List<String> ids) =>
      _prefs.setStringList(AppConstants.notifiedNotificationIdsKey, ids);

  Future<void> clearNotifiedNotificationIds() =>
      _prefs.remove(AppConstants.notifiedNotificationIdsKey);

  Future<void> clear() => _prefs.clear();
}
