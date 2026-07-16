import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity;

  static const _pollInterval = Duration(seconds: 3);
  static const _probeTimeout = Duration(seconds: 4);

  late final Stream<bool> isConnected = _buildStream()
      .distinct()
      .asBroadcastStream();

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Stream<bool> _buildStream() {
    late final StreamController<bool> controller;
    Timer? timer;
    StreamSubscription<List<ConnectivityResult>>? subscription;

    Future<void> probe() async {
      if (controller.isClosed) return;
      controller.add(await _hasInternetAccess());
    }

    controller = StreamController<bool>.broadcast(
      onListen: () {
        probe();
        timer = Timer.periodic(_pollInterval, (_) => probe());
        subscription = _connectivity.onConnectivityChanged.listen(
          (_) => probe(),
        );
      },
      onCancel: () {
        timer?.cancel();
        subscription?.cancel();
      },
    );

    return controller.stream;
  }

  Future<bool> _hasInternetAccess() async {
    if (kIsWeb) {
      final results = await _connectivity.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    }

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(_probeTimeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on Exception {
      return false;
    }
  }
}
