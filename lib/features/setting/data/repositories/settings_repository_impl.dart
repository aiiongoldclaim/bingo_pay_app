import 'package:injectable/injectable.dart';

import '../../domain/entities/public_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

@Injectable(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<PublicSettingsEntity> fetchPublicSettings() async {
    final result = await remoteDataSource.getPublicSettings();
    return result.toEntity();
  }
}
