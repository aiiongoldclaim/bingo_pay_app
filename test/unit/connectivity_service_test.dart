import 'dart:async';
import 'package:bingo_pay/core/network/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityService service;
  late StreamController<List<ConnectivityResult>> controller;

  setUp(() {
    mockConnectivity = MockConnectivity();
    controller = StreamController<List<ConnectivityResult>>.broadcast();
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => controller.stream);
    service = ConnectivityService(connectivity: mockConnectivity);
  });

  tearDown(() => controller.close());

  group('ConnectivityService', () {
    test('isConnected emits true when wifi result received', () async {
      expect(
        service.isConnected,
        emitsInOrder([true]),
      );
      controller.add([ConnectivityResult.wifi]);
    });

    test('isConnected emits false when none result received', () async {
      expect(
        service.isConnected,
        emitsInOrder([false]),
      );
      controller.add([ConnectivityResult.none]);
    });
  });
}
