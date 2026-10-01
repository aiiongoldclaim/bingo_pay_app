import 'package:injectable/injectable.dart';

import '../../domain/entities/server_health_entity.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_datasource.dart';

@Injectable(as: HealthRepository)
class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;

  HealthRepositoryImpl(this.remoteDataSource);

  @override
  Future<ServerHealthEntity> checkHealth() async {
    final result = await remoteDataSource.getHealth();
    return result.toEntity();
  }

  @override
  Future<String> ping() => remoteDataSource.ping();
}
