import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/features/health/data/models/server_health_model.dart';
import 'package:bingo_pay/features/health/domain/entities/server_health_entity.dart';
import 'package:bingo_pay/features/health/domain/repositories/health_repository.dart';
import 'package:bingo_pay/features/health/presentation/cubit/health_cubit.dart';
import 'package:bingo_pay/features/health/presentation/cubit/health_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHealthRepository extends Mock implements HealthRepository {}

/// `data` from a real /api/v1/health response (dev, 2026-10-01).
final Map<String, dynamic> _healthyJson = {
  'status': 'ok',
  'timestamp': '2026-10-01T10:34:25.180Z',
  'services': {
    'server': {'status': 'up', 'environment': 'development', 'port': 5001},
    'database': {'status': 'up', 'latencyMs': 180},
    'redis': {'status': 'up', 'latencyMs': 2},
    'queues': {
      'status': 'up',
      'items': {
        'email': {'status': 'up', 'paused': false},
      },
    },
    'socket': {'status': 'up', 'namespace': '/notifications'},
  },
};

ServerHealthEntity _healthWith(Map<String, String> statuses) =>
    ServerHealthModel.fromJson({
      'status': 'ok',
      'services': {
        for (final e in statuses.entries) e.key: {'status': e.value},
      },
    }).toEntity();

void main() {
  group('ServerHealthModel', () {
    test('parses the real health payload', () {
      final health = ServerHealthModel.fromJson(_healthyJson).toEntity();

      expect(health.status, 'ok');
      expect(health.environment, 'development');
      expect(health.services.map((s) => s.name),
          containsAll(['server', 'database', 'redis', 'queues', 'socket']));
      expect(health.service('database')!.latencyMs, 180);
      expect(health.downServices, isEmpty);
      expect(health.isUsable, isTrue);
    });

    test('is not usable when the database is down', () {
      final health = _healthWith({'server': 'up', 'database': 'down'});
      expect(health.isUsable, isFalse);
    });

    test('stays usable when only non-critical services are down', () {
      final health = _healthWith(
          {'server': 'up', 'database': 'up', 'redis': 'down', 'socket': 'down'});
      expect(health.isUsable, isTrue);
      expect(health.downServices.map((s) => s.name), ['redis', 'socket']);
    });
  });

  group('HealthCubit', () {
    late _MockHealthRepository repo;
    const greeting = 'Hello World! server is running on : 5001';

    setUp(() => repo = _MockHealthRepository());

    blocTest<HealthCubit, HealthState>(
      'emits HealthUp when /hello and /health both succeed',
      build: () {
        when(() => repo.ping()).thenAnswer((_) async => greeting);
        when(() => repo.checkHealth()).thenAnswer(
            (_) async => ServerHealthModel.fromJson(_healthyJson).toEntity());
        return HealthCubit(repo);
      },
      act: (c) => c.checkHealth(),
      expect: () => [
        const HealthChecking(),
        isA<HealthUp>()
            .having((s) => s.greeting, 'greeting', greeting)
            .having((s) => s.health?.isUsable, 'usable', true),
      ],
    );

    blocTest<HealthCubit, HealthState>(
      'emits HealthDown when the database is down',
      build: () {
        when(() => repo.ping()).thenAnswer((_) async => greeting);
        when(() => repo.checkHealth()).thenAnswer(
            (_) async => _healthWith({'server': 'up', 'database': 'down'}));
        return HealthCubit(repo);
      },
      act: (c) => c.checkHealth(),
      expect: () => [
        const HealthChecking(),
        isA<HealthDown>().having((s) => s.health, 'health', isNotNull),
      ],
    );

    blocTest<HealthCubit, HealthState>(
      'stays up when /health fails but /hello answers',
      build: () {
        when(() => repo.ping()).thenAnswer((_) async => greeting);
        when(() => repo.checkHealth())
            .thenThrow(const ServerException(statusCode: 500, message: 'x'));
        return HealthCubit(repo);
      },
      act: (c) => c.checkHealth(),
      expect: () => [
        const HealthChecking(),
        isA<HealthUp>().having((s) => s.health, 'health', isNull),
      ],
    );

    blocTest<HealthCubit, HealthState>(
      'emits HealthDown when the server is unreachable',
      build: () {
        when(() => repo.ping()).thenThrow(const NetworkException());
        when(() => repo.checkHealth()).thenThrow(const NetworkException());
        return HealthCubit(repo);
      },
      act: (c) => c.checkHealth(),
      expect: () => [
        const HealthChecking(),
        isA<HealthDown>().having((s) => s.health, 'health', isNull),
      ],
    );

    blocTest<HealthCubit, HealthState>(
      'retry from HealthDown is flagged so the screen keeps showing',
      build: () {
        when(() => repo.ping()).thenAnswer((_) async => greeting);
        when(() => repo.checkHealth()).thenAnswer(
            (_) async => ServerHealthModel.fromJson(_healthyJson).toEntity());
        return HealthCubit(repo);
      },
      seed: () => const HealthDown('down'),
      act: (c) => c.checkHealth(),
      expect: () => [
        const HealthChecking(isRetry: true),
        isA<HealthUp>(),
      ],
    );
  });
}
