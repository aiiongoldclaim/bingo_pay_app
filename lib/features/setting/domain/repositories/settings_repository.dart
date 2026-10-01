import '../entities/public_settings_entity.dart';

abstract class SettingsRepository {
  Future<PublicSettingsEntity> fetchPublicSettings();
}
