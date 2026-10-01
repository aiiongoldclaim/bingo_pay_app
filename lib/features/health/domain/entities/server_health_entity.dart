class ServiceHealthEntity {
  final String name;
  final String status;
  final int? latencyMs;

  ServiceHealthEntity({
    required this.name,
    required this.status,
    this.latencyMs,
  });

  bool get isUp => status.toLowerCase() == 'up';
}

class ServerHealthEntity {
  /// Overall status reported by the backend, e.g. "ok".
  final String status;
  final DateTime? checkedAt;
  final String? environment;
  final List<ServiceHealthEntity> services;

  ServerHealthEntity({
    required this.status,
    this.checkedAt,
    this.environment,
    required this.services,
  });

  /// Services the app cannot work without. Redis, queues and the socket can
  /// be down without blocking the user (the app degrades instead).
  static const criticalServices = {'server', 'database'};

  ServiceHealthEntity? service(String name) {
    for (final s in services) {
      if (s.name == name) return s;
    }
    return null;
  }

  List<ServiceHealthEntity> get downServices =>
      services.where((s) => !s.isUp).toList();

  bool get isUsable => criticalServices.every((name) {
        final s = service(name);
        // A service missing from the response is not treated as down.
        return s == null || s.isUp;
      });
}
