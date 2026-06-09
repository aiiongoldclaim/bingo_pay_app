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

  Future<void> clear() => _prefs.clear();
}
