import '../entities/server_health_entity.dart';

abstract class HealthRepository {
  Future<ServerHealthEntity> checkHealth();

  /// Returns the server greeting; throws if the server can't be reached.
  Future<String> ping();
}
