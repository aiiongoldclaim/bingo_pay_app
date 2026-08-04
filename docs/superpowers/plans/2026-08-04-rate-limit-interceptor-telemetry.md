# Rate-Limit Interceptor & Telemetry (Vendor App) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the vendor app to parity with the customer app's 429 handling — today a 429 falls through to a generic `ServerException` — and add the same typed retry policy (silent retry for short waits, fail-fast otherwise) plus Sentry telemetry on every rate-limit event.

**Architecture:** Add the `RateLimitException`/`RateLimitFailure` types the customer app already has, then extract the 429 handling into a standalone `RateLimitInterceptor` whose retry decision is a pure, unit-testable function — same design as the customer app's plan, implemented independently since the two apps share no package. A new `CurrentScreenTracker` singleton (updated by a `GoRouter` listener) lets the interceptor tag telemetry with the active screen. Sentry is initialized with an empty placeholder DSN (a documented no-op) so the wiring ships now.

**Tech Stack:** Flutter, `dio` (HTTP + interceptors), `flutter_bloc` + `get_it`/`injectable` (DI), `go_router`, `flutter_flavor`, `sentry_flutter` (new), `mocktail` + `flutter_test` (existing dev dependency — this plan adds the app's first `test/` directory).

## Global Constraints

- No client-side sliding-window rate counter — the interceptor only reacts to a 429 it already received.
- Mutations (POST/PUT/PATCH/DELETE) never auto-retry on 429 in this plan — no idempotency-key mechanism exists yet (a later sub-project), so retrying a mutation risks a double-submit.
- A GET gets **at most one** silent retry, and only if the wait is ≤5000ms total (`Retry-After` header if present, else a 1000ms+jitter backoff). Longer waits or a second 429 fail fast.
- The existing 401 → `SessionExpiryNotifier` behavior in `ErrorInterceptor` must be preserved exactly as-is.
- No dedicated "High Demand" widget for this plan — the existing generic `AppErrorWidget` already renders any `Failure.message` with a retry button, so `RateLimitFailure` needs no new UI code.
- Sentry DSN is an empty string placeholder in all three flavors for now; `SentryFlutter.init` with an empty DSN is a documented no-op.
- No new dependency beyond `sentry_flutter`.

---

### Task 1: Add `RateLimitException` / `RateLimitFailure` (parity with customer app)

**Files:**
- Modify: `lib/core/error/exceptions.dart`
- Modify: `lib/core/error/failures.dart`
- Modify: `lib/core/error/error_handler.dart`
- Test: `test/core/error/error_handler_test.dart`

**Interfaces:**
- Produces: `RateLimitException({required String message, int? retryAfterSeconds})`, `RateLimitFailure({required String message, int? retryAfterSeconds}) extends Failure`. Consumed by Task 4 (`ErrorInterceptor`).

- [ ] **Step 1: Write the failing test**

```dart
// test/core/error/error_handler_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bingo_pay/core/error/error_handler.dart';
import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/core/error/failures.dart';

void main() {
  test('maps RateLimitException to RateLimitFailure, preserving retry timing',
      () {
    const exception = RateLimitException(
      message: 'High server load. Please wait a moment and try again.',
      retryAfterSeconds: 30,
    );

    final failure = ErrorHandler.mapErrorToFailure(exception);

    expect(failure, isA<RateLimitFailure>());
    final rateLimitFailure = failure as RateLimitFailure;
    expect(rateLimitFailure.message, exception.message);
    expect(rateLimitFailure.retryAfterSeconds, 30);
  });

  test('unwraps a RateLimitException carried inside a DioException', () {
    const exception = RateLimitException(
      message: 'Too many requests',
      retryAfterSeconds: 5,
    );
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/products'),
      error: exception,
    );

    final failure = ErrorHandler.mapErrorToFailure(dioError);

    expect(failure, isA<RateLimitFailure>());
    expect((failure as RateLimitFailure).retryAfterSeconds, 5);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/error/error_handler_test.dart`
Expected: FAIL — `RateLimitException`/`RateLimitFailure` don't exist yet.

- [ ] **Step 3: Write minimal implementation**

Append to `lib/core/error/exceptions.dart`:

```dart
class RateLimitException implements Exception {
  final String message;
  final int? retryAfterSeconds;
  const RateLimitException({
    required this.message,
    this.retryAfterSeconds,
  });
}
```

Append to `lib/core/error/failures.dart`:

```dart
class RateLimitFailure extends Failure {
  final int? retryAfterSeconds;

  const RateLimitFailure({
    required String message,
    this.retryAfterSeconds,
  }) : super(message);

  @override
  List<Object?> get props => [message, retryAfterSeconds];
}
```

In `lib/core/error/error_handler.dart`, add a case to the `switch`:

```dart
    return switch (resolved) {
      ServerException e => ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          serverMessage: e.message,
        ),
      NetworkException _ => const NetworkFailure(),
      AuthException e => AuthFailure(message: e.message),
      ValidationException e => ValidationFailure(
          message: e.message,
          fieldErrors: e.fieldErrors,
        ),
      RateLimitException e => RateLimitFailure(
          message: e.message,
          retryAfterSeconds: e.retryAfterSeconds,
        ),
      CacheException e => CacheFailure(message: e.message),
      _ => UnknownFailure(resolved.toString()),
    };
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/error/error_handler_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/error/exceptions.dart lib/core/error/failures.dart lib/core/error/error_handler.dart test/core/error/error_handler_test.dart
git commit -m "feat(error): add RateLimitException/RateLimitFailure, matching the customer app"
```

---

### Task 2: `CurrentScreenTracker` service

**Files:**
- Create: `lib/core/services/current_screen_tracker.dart`
- Test: `test/core/services/current_screen_tracker_test.dart`

**Interfaces:**
- Produces: `CurrentScreenTracker` — `String get current`, `void update(String path)`. Registered via `@singleton`, consumed by Task 3 (router wiring) and Task 4 (`RateLimitInterceptor`).

- [ ] **Step 1: Write the failing test**

```dart
// test/core/services/current_screen_tracker_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bingo_pay/core/services/current_screen_tracker.dart';

void main() {
  test('starts as unknown and reflects the latest update', () {
    final tracker = CurrentScreenTracker();
    expect(tracker.current, 'unknown');

    tracker.update('/vendor/home');
    expect(tracker.current, '/vendor/home');

    tracker.update('/vendor/products');
    expect(tracker.current, '/vendor/products');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/services/current_screen_tracker_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/services/current_screen_tracker.dart
import 'package:injectable/injectable.dart';

/// Tracks the most recently navigated-to route path so components without
/// a BuildContext (e.g. Dio interceptors) can tag telemetry with "which
/// screen was the user on" without every API call site passing one in.
@singleton
class CurrentScreenTracker {
  String _current = 'unknown';

  String get current => _current;

  void update(String path) => _current = path;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/services/current_screen_tracker_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/current_screen_tracker.dart test/core/services/current_screen_tracker_test.dart
git commit -m "feat(telemetry): add CurrentScreenTracker for screen-tagged interceptor logging"
```

---

### Task 3: Add Sentry dependency (needed before Task 4 compiles)

**Files:**
- Modify: `pubspec.yaml` (via `flutter pub add`)

- [ ] **Step 1: Add the dependency**

Run: `flutter pub add sentry_flutter`
Expected: `pubspec.yaml` and `pubspec.lock` updated with the latest compatible `sentry_flutter` version.

- [ ] **Step 2: Confirm it resolves**

Run: `flutter pub get`
Expected: succeeds with no errors.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add sentry_flutter dependency"
```

---

### Task 4: `RateLimitOutcome` + `RateLimitInterceptor` (retry policy)

**Files:**
- Create: `lib/core/api/interceptors/rate_limit_outcome.dart`
- Create: `lib/core/api/interceptors/rate_limit_interceptor.dart`
- Test: `test/core/api/interceptors/rate_limit_interceptor_test.dart`

**Interfaces:**
- Consumes: `CurrentScreenTracker` (Task 2) — reads `.current`. `sentry_flutter` (Task 3).
- Produces: `RateLimitOutcome` (`RateLimitResolved(Response response)` / `RateLimitFailed(DioException error)`), `RateLimitInterceptor` with `int? decideWaitMs({required bool alreadyRetried, required bool isMutation, required int? retryAfterSeconds})` and `Future<RateLimitOutcome> resolve(DioException err)`. Consumed by Task 5 (`ErrorInterceptor` wiring).

- [ ] **Step 1: Write the failing tests**

```dart
// test/core/api/interceptors/rate_limit_interceptor_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bingo_pay/core/api/interceptors/rate_limit_interceptor.dart';
import 'package:bingo_pay/core/api/interceptors/rate_limit_outcome.dart';
import 'package:bingo_pay/core/services/current_screen_tracker.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late CurrentScreenTracker screenTracker;
  late RateLimitInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/fallback'));
  });

  setUp(() {
    dio = MockDio();
    screenTracker = CurrentScreenTracker();
    interceptor = RateLimitInterceptor(
      dio,
      screenTracker,
      delay: (_) async {},
      jitterMs: () => 0,
    );
  });

  DioException buildError({
    required String method,
    int? retryAfterSeconds,
    bool alreadyRetried = false,
  }) {
    final options = RequestOptions(
      path: '/api/v1/vendor-orders',
      method: method,
      extra: {'rateLimitRetried': alreadyRetried},
    );
    final response = Response<dynamic>(
      requestOptions: options,
      statusCode: 429,
      headers: Headers.fromMap({
        if (retryAfterSeconds != null) 'retry-after': ['$retryAfterSeconds'],
      }),
    );
    return DioException(
      requestOptions: options,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  group('decideWaitMs', () {
    test('GET with short Retry-After retries silently', () {
      final wait = interceptor.decideWaitMs(
        alreadyRetried: false,
        isMutation: false,
        retryAfterSeconds: 3,
      );
      expect(wait, 3000);
    });

    test('GET with long Retry-After fails fast', () {
      final wait = interceptor.decideWaitMs(
        alreadyRetried: false,
        isMutation: false,
        retryAfterSeconds: 10,
      );
      expect(wait, isNull);
    });

    test('GET with no header backs off under the ceiling', () {
      final wait = interceptor.decideWaitMs(
        alreadyRetried: false,
        isMutation: false,
        retryAfterSeconds: null,
      );
      expect(wait, RateLimitInterceptor.baseBackoffMs);
    });

    test('mutation never retries even with a short Retry-After', () {
      final wait = interceptor.decideWaitMs(
        alreadyRetried: false,
        isMutation: true,
        retryAfterSeconds: 1,
      );
      expect(wait, isNull);
    });

    test('already-retried request never retries again', () {
      final wait = interceptor.decideWaitMs(
        alreadyRetried: true,
        isMutation: false,
        retryAfterSeconds: 1,
      );
      expect(wait, isNull);
    });
  });

  group('resolve', () {
    test('retries once and resolves on success', () async {
      final err = buildError(method: 'GET', retryAfterSeconds: 2);
      final successResponse = Response<dynamic>(
        requestOptions: err.requestOptions,
        statusCode: 200,
        data: {'ok': true},
      );
      when(() => dio.fetch<dynamic>(any()))
          .thenAnswer((_) async => successResponse);

      final outcome = await interceptor.resolve(err);

      expect(outcome, isA<RateLimitResolved>());
      expect(err.requestOptions.extra['rateLimitRetried'], true);
      verify(() => dio.fetch<dynamic>(any())).called(1);
    });

    test('fails fast without calling dio.fetch when wait exceeds the ceiling',
        () async {
      final err = buildError(method: 'GET', retryAfterSeconds: 30);

      final outcome = await interceptor.resolve(err);

      expect(outcome, isA<RateLimitFailed>());
      verifyNever(() => dio.fetch<dynamic>(any()));
    });

    test('never retries a mutation', () async {
      final err = buildError(method: 'POST', retryAfterSeconds: 1);

      final outcome = await interceptor.resolve(err);

      expect(outcome, isA<RateLimitFailed>());
      verifyNever(() => dio.fetch<dynamic>(any()));
    });

    test('retry that also 429s fails fast without looping', () async {
      final err = buildError(method: 'GET', retryAfterSeconds: 2);
      final secondError = DioException(
        requestOptions: err.requestOptions,
        response: Response<dynamic>(
          requestOptions: err.requestOptions,
          statusCode: 429,
        ),
        type: DioExceptionType.badResponse,
      );
      when(() => dio.fetch<dynamic>(any())).thenThrow(secondError);

      final outcome = await interceptor.resolve(err);

      expect(outcome, isA<RateLimitFailed>());
      verify(() => dio.fetch<dynamic>(any())).called(1);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/api/interceptors/rate_limit_interceptor_test.dart`
Expected: FAIL — neither source file exists yet.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/api/interceptors/rate_limit_outcome.dart
import 'package:dio/dio.dart';

sealed class RateLimitOutcome {
  const RateLimitOutcome();
}

class RateLimitResolved extends RateLimitOutcome {
  final Response<dynamic> response;
  const RateLimitResolved(this.response);
}

class RateLimitFailed extends RateLimitOutcome {
  final DioException error;
  const RateLimitFailed(this.error);
}
```

```dart
// lib/core/api/interceptors/rate_limit_interceptor.dart
import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../services/current_screen_tracker.dart';
import 'rate_limit_outcome.dart';

typedef DelayFn = Future<void> Function(Duration duration);

/// Central retry policy for HTTP 429 responses.
///
/// GET requests get one silent retry if the wait stays under
/// [maxSilentWaitMs]; mutations never auto-retry here because retrying a
/// non-idempotent request without a server-honored idempotency key (not
/// built yet) risks a double-submit. The decision logic is exposed as a
/// pure function ([decideWaitMs]) so it's testable without a real Dio call.
class RateLimitInterceptor {
  static const maxSilentWaitMs = 5000;
  static const baseBackoffMs = 1000;
  static const _retriedKey = 'rateLimitRetried';

  final Dio _dio;
  final CurrentScreenTracker _screenTracker;
  final DelayFn _delay;
  final int Function() _jitterMs;

  RateLimitInterceptor(
    this._dio,
    this._screenTracker, {
    DelayFn delay = Future.delayed,
    int Function() jitterMs = _defaultJitter,
  })  : _delay = delay,
        _jitterMs = jitterMs;

  static int _defaultJitter() => Random().nextInt(250);

  int? decideWaitMs({
    required bool alreadyRetried,
    required bool isMutation,
    required int? retryAfterSeconds,
  }) {
    if (alreadyRetried || isMutation) return null;
    if (retryAfterSeconds != null) {
      final ms = retryAfterSeconds * 1000;
      return ms <= maxSilentWaitMs ? ms : null;
    }
    final backoffMs = baseBackoffMs + _jitterMs();
    return backoffMs <= maxSilentWaitMs ? backoffMs : null;
  }

  Future<RateLimitOutcome> resolve(DioException err) async {
    final requestOptions = err.requestOptions;
    final alreadyRetried = requestOptions.extra[_retriedKey] == true;
    final isMutation = _isMutation(requestOptions.method);
    final retryAfterSeconds = _extractRetryAfterSeconds(err.response);

    final waitMs = decideWaitMs(
      alreadyRetried: alreadyRetried,
      isMutation: isMutation,
      retryAfterSeconds: retryAfterSeconds,
    );

    if (waitMs == null) {
      _logTelemetry(
        requestOptions: requestOptions,
        retryAfterSeconds: retryAfterSeconds,
        retryAttempted: false,
        retrySucceeded: null,
      );
      return RateLimitFailed(err);
    }

    await _delay(Duration(milliseconds: waitMs));
    requestOptions.extra[_retriedKey] = true;

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      _logTelemetry(
        requestOptions: requestOptions,
        retryAfterSeconds: retryAfterSeconds,
        retryAttempted: true,
        retrySucceeded: true,
      );
      return RateLimitResolved(response);
    } on DioException catch (retryError) {
      _logTelemetry(
        requestOptions: requestOptions,
        retryAfterSeconds: retryAfterSeconds,
        retryAttempted: true,
        retrySucceeded: false,
      );
      return RateLimitFailed(retryError);
    }
  }

  bool _isMutation(String method) {
    final m = method.toUpperCase();
    return m == 'POST' || m == 'PUT' || m == 'DELETE' || m == 'PATCH';
  }

  int? _extractRetryAfterSeconds(Response? response) {
    final header = response?.headers.value('retry-after');
    return header != null ? int.tryParse(header) : null;
  }

  void _logTelemetry({
    required RequestOptions requestOptions,
    required int? retryAfterSeconds,
    required bool retryAttempted,
    required bool? retrySucceeded,
  }) {
    // Sentry.captureMessage is a documented no-op before SentryFlutter.init
    // runs (or with an empty DSN), so this is safe to call unconditionally
    // — including from these unit tests, which never initialize Sentry.
    Sentry.captureMessage(
      'Rate limited',
      level: SentryLevel.warning,
      withScope: (scope) {
        scope.setContexts('rate_limit', {
          'endpoint': requestOptions.path,
          'method': requestOptions.method,
          'screen': _screenTracker.current,
          'retryAfterSeconds': retryAfterSeconds,
          'retryAttempted': retryAttempted,
          'retrySucceeded': retrySucceeded,
        });
      },
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/api/interceptors/rate_limit_interceptor_test.dart`
Expected: PASS (10 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/core/api/interceptors/rate_limit_outcome.dart lib/core/api/interceptors/rate_limit_interceptor.dart test/core/api/interceptors/rate_limit_interceptor_test.dart
git commit -m "feat(api): add RateLimitInterceptor with a testable 429 retry policy"
```

---

### Task 5: Wire `RateLimitInterceptor` into `ErrorInterceptor` and `ApiClient`

**Files:**
- Modify: `lib/core/api/interceptors/error_interceptor.dart`
- Modify: `lib/core/api/api_client.dart`
- Test: `test/core/api/interceptors/error_interceptor_test.dart`

**Interfaces:**
- Consumes: `RateLimitInterceptor.resolve` (Task 4), `RateLimitOutcome` (Task 4), `SessionExpiryNotifier` (existing).
- Produces: `ErrorInterceptor(SessionExpiryNotifier sessionExpiryNotifier, RateLimitInterceptor rateLimitInterceptor)`.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/api/interceptors/error_interceptor_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bingo_pay/core/api/interceptors/error_interceptor.dart';
import 'package:bingo_pay/core/api/interceptors/rate_limit_interceptor.dart';
import 'package:bingo_pay/core/api/interceptors/rate_limit_outcome.dart';
import 'package:bingo_pay/core/api/session_expiry_notifier.dart';
import 'package:bingo_pay/core/error/exceptions.dart';

class MockRateLimitInterceptor extends Mock implements RateLimitInterceptor {}

class RecordingHandler extends ErrorInterceptorHandler {
  Object? resolved;
  DioException? rejected;

  @override
  void resolve(Response response) {
    resolved = response;
  }

  @override
  void reject(DioException err) {
    rejected = err;
  }
}

void main() {
  late SessionExpiryNotifier sessionExpiryNotifier;
  late MockRateLimitInterceptor rateLimitInterceptor;
  late ErrorInterceptor errorInterceptor;

  setUpAll(() {
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/fallback')),
    );
  });

  setUp(() {
    sessionExpiryNotifier = SessionExpiryNotifier();
    rateLimitInterceptor = MockRateLimitInterceptor();
    errorInterceptor = ErrorInterceptor(
      sessionExpiryNotifier,
      rateLimitInterceptor,
    );
  });

  test('a 429 that the rate limiter resolves is passed through as success',
      () async {
    final options = RequestOptions(path: '/api/v1/vendor-orders');
    final err = DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 429),
      type: DioExceptionType.badResponse,
    );
    final resolvedResponse = Response<dynamic>(
      requestOptions: options,
      statusCode: 200,
    );
    when(() => rateLimitInterceptor.resolve(err))
        .thenAnswer((_) async => RateLimitResolved(resolvedResponse));

    final handler = RecordingHandler();
    await errorInterceptor.onError(err, handler);

    expect(handler.resolved, resolvedResponse);
    expect(handler.rejected, isNull);
  });

  test('a 429 that the rate limiter fails maps to RateLimitException',
      () async {
    final options = RequestOptions(path: '/api/v1/vendor-orders');
    final failedErr = DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: 429,
        headers: Headers.fromMap({
          'retry-after': ['12'],
        }),
        data: {'message': 'Too Many Requests'},
      ),
      type: DioExceptionType.badResponse,
    );
    when(() => rateLimitInterceptor.resolve(any()))
        .thenAnswer((_) async => RateLimitFailed(failedErr));

    final handler = RecordingHandler();
    await errorInterceptor.onError(failedErr, handler);

    expect(handler.resolved, isNull);
    final rejected = handler.rejected!.error as RateLimitException;
    expect(rejected.message, 'Too Many Requests');
    expect(rejected.retryAfterSeconds, 12);
  });

  test('non-429 errors bypass the rate limiter entirely', () async {
    final options = RequestOptions(path: '/api/v1/vendor-orders');
    final err = DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: 500,
        data: {'message': 'Server error'},
      ),
      type: DioExceptionType.badResponse,
    );

    final handler = RecordingHandler();
    await errorInterceptor.onError(err, handler);

    verifyNever(() => rateLimitInterceptor.resolve(any()));
    expect(handler.rejected!.error, isA<ServerException>());
  });

  test('a 401 still notifies SessionExpiryNotifier', () async {
    final options = RequestOptions(path: '/auth/me');
    final err = DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: 401,
        data: {'message': 'Unauthorized'},
      ),
      type: DioExceptionType.badResponse,
    );

    final events = <void>[];
    final sub = sessionExpiryNotifier.onSessionExpired.listen(events.add);

    final handler = RecordingHandler();
    await errorInterceptor.onError(err, handler);
    await Future<void>.delayed(Duration.zero);

    expect(events, hasLength(1));
    await sub.cancel();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/api/interceptors/error_interceptor_test.dart`
Expected: FAIL — `ErrorInterceptor` doesn't yet take a second constructor argument.

- [ ] **Step 3: Write minimal implementation**

Replace the full contents of `lib/core/api/interceptors/error_interceptor.dart`:

```dart
import 'package:dio/dio.dart';
import '../../error/exceptions.dart';
import '../session_expiry_notifier.dart';
import 'rate_limit_interceptor.dart';
import 'rate_limit_outcome.dart';

class ErrorInterceptor extends Interceptor {
  final SessionExpiryNotifier _sessionExpiryNotifier;
  final RateLimitInterceptor _rateLimitInterceptor;

  ErrorInterceptor(this._sessionExpiryNotifier, this._rateLimitInterceptor);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      _sessionExpiryNotifier.notify();
    }

    if (err.response?.statusCode == 429) {
      final outcome = await _rateLimitInterceptor.resolve(err);
      switch (outcome) {
        case RateLimitResolved(:final response):
          handler.resolve(response);
        case RateLimitFailed(:final error):
          _rejectWithMappedException(error, handler);
      }
      return;
    }

    _rejectWithMappedException(err, handler);
  }

  void _rejectWithMappedException(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final exception = _mapDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  Exception _mapDioError(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }

    final response = err.response;
    if (response == null) return const NetworkException();

    final message = _extractMessage(response.data) ??
        (response.statusCode == 429
            ? 'High server load. Please wait a moment and try again.'
            : 'Server error');
    final fieldErrors = _extractFieldErrors(response.data);

    return switch (response.statusCode) {
      401 => AuthException(message: message),
      422 => ValidationException(message: message, fieldErrors: fieldErrors),
      429 => RateLimitException(
          message: message,
          retryAfterSeconds: _extractRetryAfter(response),
        ),
      _ => ServerException(statusCode: response.statusCode, message: message),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) return data['message'] as String?;
    return null;
  }

  Map<String, String> _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return Map<String, String>.from(data['errors'] as Map);
    }
    return {};
  }

  int? _extractRetryAfter(Response response) {
    final retryAfter = response.headers.value('retry-after');
    if (retryAfter != null) {
      return int.tryParse(retryAfter);
    }
    return null;
  }
}
```

Update `lib/core/api/api_client.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../config/app_config.dart';
import '../services/current_screen_tracker.dart';
import '../storage/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/rate_limit_interceptor.dart';
import 'session_expiry_notifier.dart';

@singleton
class ApiClient {
  late final Dio dio;

  ApiClient(
    SecureStorageService storage,
    SessionExpiryNotifier sessionExpiryNotifier,
    CurrentScreenTracker screenTracker,
  ) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(
          seconds: AppConfig.connectTimeoutSeconds,
        ),
        receiveTimeout: const Duration(
          seconds: AppConfig.receiveTimeoutSeconds,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': AppConfig.apiKey,
        },
      ),
    );

    final rateLimitInterceptor = RateLimitInterceptor(dio, screenTracker);

    dio.interceptors.addAll([
      AuthInterceptor(storage),
      LoggingInterceptor(),
      ErrorInterceptor(sessionExpiryNotifier, rateLimitInterceptor),
    ]);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/api/interceptors/error_interceptor_test.dart`
Expected: PASS (4 tests)

- [ ] **Step 5: Run the full existing test suite to check for regressions**

Run: `flutter test`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/core/api/interceptors/error_interceptor.dart lib/core/api/api_client.dart test/core/api/interceptors/error_interceptor_test.dart
git commit -m "feat(api): route 429s through RateLimitInterceptor before the failure pipeline"
```

---

### Task 6: Wire screen tracking into `AppRouter`

**Files:**
- Modify: `lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `CurrentScreenTracker` (Task 2).

**Why no automated test:** `AppRouter`'s constructor wires in every vendor feature screen via the DI graph — instantiating it in a test means standing up that whole graph for a one-line assertion, disproportionate to what it protects. Verified instead by the manual check in Task 8. The logic that actually matters (the retry policy) already has full unit coverage in Task 4.

- [ ] **Step 1: Modify `AppRouter` to accept `CurrentScreenTracker` and track navigation**

`lib/core/router/app_router.dart` currently has two commented-out earlier drafts above the active class (`@lazySingleton class AppRouter` starting around line 231) — only touch the active class; leave the commented-out blocks untouched.

Add the import near the other relative imports in the active section:

```dart
import '../services/current_screen_tracker.dart';
```

Change the active class to:

```dart
@lazySingleton
class AppRouter {
  late final GoRouter router;
  RouteAuthState _authState = const RouteAuthState.loading();
  final CurrentScreenTracker _screenTracker;

  AppRouter(this._screenTracker) {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      observers: [UnfocusNavigatorObserver()],
      redirect: (context, state) => RouteGuard.redirect(
        location: state.matchedLocation,
        authState: _authState,
      ),
      routes: [
        // ... existing routes list, unchanged ...
      ],
    );
    router.addListener(_trackScreen);
  }

  void _trackScreen() {
    final path = router.routerDelegate.currentConfiguration.uri.toString();
    _screenTracker.update(path);
  }

  void updateAuthState(RouteAuthState state) {
    _authState = state;
    router.refresh();
  }
}
```

(Only the constructor signature and the two new lines/method are new — the `routes: [ ... ]` list body and the `observers:` line are untouched.)

- [ ] **Step 2: Regenerate injectable's DI graph**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: succeeds and updates `lib/core/di/injection.config.dart` to inject `CurrentScreenTracker` into both `ApiClient` and `AppRouter`. Do not hand-edit `injection.config.dart` — it's generated.

- [ ] **Step 3: Confirm the app still compiles and analyzes clean**

Run: `flutter analyze`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/app_router.dart lib/core/di/injection.config.dart
git commit -m "feat(telemetry): track the active route for rate-limit telemetry"
```

---

### Task 7: Initialize Sentry (init + flavor DSNs)

**Files:**
- Modify: `lib/app/bootstrap.dart`
- Modify: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`

- [ ] **Step 1: Add the placeholder DSN to each flavor**

Add `'sentryDsn': ''` to each `variables` map, e.g. in `main_dev.dart`:

```dart
  FlavorConfig(
    name: 'dev',
    color: Colors.green,
    variables: const {
      'apiBaseUrl': 'http://13.159.7.199:5001',
      'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
      'appName': 'Bingo Pay DEV',
      'enableLogging': true,
      'enableAnalytics': false,
      'sentryDsn': '',
    },
  );
```

Apply the same `'sentryDsn': ''` addition to `main_staging.dart` and `main_prod.dart`'s `variables` maps.

- [ ] **Step 2: Wrap `runApp` with `SentryFlutter.init`**

Replace `lib/app/bootstrap.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../core/config/flavor_config.dart';
import '../core/di/injection.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(FlavorConfig.instance.name ?? 'prod');
  Bloc.observer = AppBlocObserver();

  await SentryFlutter.init(
    (options) {
      options.dsn = FlavorConfig.instance.variables['sentryDsn'] as String? ?? '';
      options.environment = FlavorConfig.instance.name;
    },
    appRunner: () => runApp(
      FlavorConfig.instance.isProduction
          ? const App()
          : FlavorBanner(child: const App()),
    ),
  );
}
```

- [ ] **Step 3: Confirm the app still builds**

Run: `flutter analyze`
Expected: no errors.

Run: `flutter test`
Expected: PASS — an empty DSN means Sentry is disabled at runtime, so no test needs to mock it.

- [ ] **Step 4: Commit**

```bash
git add lib/app/bootstrap.dart lib/main_dev.dart lib/main_staging.dart lib/main_prod.dart
git commit -m "feat(telemetry): initialize Sentry with a placeholder DSN"
```

---

### Task 8: Manual verification against a real 429

**No files changed** — this is a verification pass, not a code task.

- [ ] **Step 1: Trigger a real 429 locally**

In `the_vaults_backend`, temporarily set a very low limit so a single screen trips it, then start the backend:

```bash
THROTTLE_LIMIT=2 THROTTLE_TTL_MS=60000 npm run start:dev
```

- [ ] **Step 2: Point the vendor app's dev flavor at the local backend**

Temporarily set `apiBaseUrl` in `lib/main_dev.dart` to your local backend's address, then run:

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

- [ ] **Step 3: Confirm behavior matches the retry table**

- Rapidly reload the vendor products or orders list (a GET) until you trip the limit. With `THROTTLE_TTL_MS=60000`, `Retry-After` will exceed 5s, so you should see the generic `AppErrorWidget` with the "High server load..." message and a working retry button — not a silent hang.
- To see the silent-retry path, lower `THROTTLE_TTL_MS` to under 5000 (e.g. `THROTTLE_TTL_MS=3000`) and repeat — the screen should recover with no visible error in the common case.
- Trigger a mutation (e.g. update order status) while throttled — confirm it fails immediately with the error UI, never silently retries, and does not apply the update twice.
- Trigger a 401 (e.g. by clearing stored tokens mid-session) and confirm the existing session-expiry logout flow still fires — this plan must not have broken it.

- [ ] **Step 4: Revert the temporary local-testing changes**

```bash
git checkout -- lib/main_dev.dart
```

- [ ] **Step 5: Confirm acceptance criteria**

- [ ] Vendor app's behavior on 429 is no longer a generic server error — it's a recognized `RateLimitFailure`, matching the customer app's classification.
- [ ] A 429 on a GET with `Retry-After` ≤5s was invisible to the user (silent retry succeeded).
- [ ] A 429 on a GET with a longer wait, or on any mutation, surfaced the typed failure UI — no double-submission.
- [ ] The 401 → session-expiry flow still works, unaffected by this change.
- [ ] No client-side sliding-window rate counter was introduced.
