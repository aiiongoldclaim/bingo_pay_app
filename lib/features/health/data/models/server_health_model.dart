import '../../domain/entities/server_health_entity.dart';

class ServiceHealthModel {
  final String name;
  final String status;
  final int? latencyMs;

  ServiceHealthModel({
    required this.name,
    required this.status,
    this.latencyMs,
  });

  factory ServiceHealthModel.fromJson(String name, Map<String, dynamic> json) {
    final latency = json['latencyMs'];
    return ServiceHealthModel(
      name: name,
      status: json['status']?.toString() ?? 'unknown',
      latencyMs: latency is num ? latency.toInt() : null,
    );
  }

  ServiceHealthEntity toEntity() => ServiceHealthEntity(
        name: name,
        status: status,
        latencyMs: latencyMs,
      );
}

class ServerHealthModel {
  final String status;
  final DateTime? checkedAt;
  final String? environment;
  final List<ServiceHealthModel> services;

  ServerHealthModel({
    required this.status,
    this.checkedAt,
    this.environment,
    required this.services,
  });

  factory ServerHealthModel.fromJson(Map<String, dynamic> json) {
    final servicesJson = json['services'];
    final services = <ServiceHealthModel>[];
    String? environment;

    if (servicesJson is Map<String, dynamic>) {
      servicesJson.forEach((name, value) {
        if (value is Map<String, dynamic>) {
          services.add(ServiceHealthModel.fromJson(name, value));
          if (name == 'server') environment = value['environment']?.toString();
        }
      });
    }

    return ServerHealthModel(
      status: json['status']?.toString() ?? 'unknown',
      checkedAt: DateTime.tryParse(json['timestamp']?.toString() ?? ''),
      environment: environment,
      services: services,
    );
  }

  ServerHealthEntity toEntity() => ServerHealthEntity(
        status: status,
        checkedAt: checkedAt,
        environment: environment,
        services: services.map((s) => s.toEntity()).toList(),
      );
}
