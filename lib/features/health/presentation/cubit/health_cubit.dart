import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/server_health_entity.dart';
import '../../domain/repositories/health_repository.dart';
import 'health_state.dart';

@injectable
class HealthCubit extends Cubit<HealthState> {
  final HealthRepository repository;

  HealthCubit(this.repository) : super(HealthInitial());

  static const _unreachableMessage = AppStrings.serverDownMessage;
  static const _unhealthyMessage = AppStrings.serverDownMessage;

  /// Runs `/hello` (is the server reachable?) and `/health` (are its
  /// services up?) in parallel.
  Future<void> checkHealth() async {
    if (state is HealthChecking) return;
    emit(HealthChecking(isRetry: state is HealthDown));

    final results = await Future.wait([
      _capture(repository.ping),
      _capture(repository.checkHealth),
    ]);
    final ping = results[0];
    final healthResult = results[1];

    if (ping.error != null) debugPrint('Hello ping failed: ${ping.error}');
    if (healthResult.error != null) {
      debugPrint('Health check failed: ${healthResult.error}');
    }

    final health = healthResult.value as ServerHealthEntity?;

    if (health != null) {
      if (!health.isUsable) {
        emit(HealthDown(_unhealthyMessage, health: health));
        return;
      }
      if (health.downServices.isNotEmpty) {
        debugPrint(
          'Health: degraded — down: '
          '${health.downServices.map((s) => s.name).join(', ')}',
        );
      }
      emit(HealthUp(health, greeting: ping.value as String?));
      return;
    }

    // No health report: the server is still usable if it answered /hello.
    if (ping.error == null) {
      emit(HealthUp(null, greeting: ping.value as String?));
    } else {
      emit(const HealthDown(_unreachableMessage));
    }
  }

  static Future<_Result> _capture(Future<Object?> Function() call) async {
    try {
      return _Result(value: await call());
    } catch (e) {
      return _Result(error: e);
    }
  }
}

class _Result {
  final Object? value;
  final Object? error;

  const _Result({this.value, this.error});
}
