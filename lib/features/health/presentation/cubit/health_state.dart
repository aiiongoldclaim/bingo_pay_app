import 'package:equatable/equatable.dart';

import '../../domain/entities/server_health_entity.dart';

abstract class HealthState extends Equatable {
  const HealthState();

  @override
  List<Object?> get props => [];
}

class HealthInitial extends HealthState {}

class HealthChecking extends HealthState {
  /// True while retrying from the server-down screen, so it can show a
  /// spinner instead of disappearing.
  final bool isRetry;

  const HealthChecking({this.isRetry = false});

  @override
  List<Object?> get props => [isRetry];
}

class HealthUp extends HealthState {
  /// Null when /health failed but /hello confirmed the server is reachable.
  final ServerHealthEntity? health;

  /// Greeting from /hello, null if that call failed.
  final String? greeting;

  const HealthUp(this.health, {this.greeting});

  @override
  List<Object?> get props => [health, greeting];
}

class HealthDown extends HealthState {
  final String message;

  /// Null when the server couldn't be reached at all.
  final ServerHealthEntity? health;

  const HealthDown(this.message, {this.health});

  @override
  List<Object?> get props => [message, health];
}
