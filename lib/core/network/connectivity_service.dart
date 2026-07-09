import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity;

  // connectivity_plus only reports whether a network interface (wifi/
  // cellular) is up — it does NOT guarantee actual internet reachability.
  // A WiFi network with no WAN access (or one whose interface state never
  // changes at all) would otherwise leave the app stuck showing "no
  // internet" forever, even after real access comes back. So isConnected is
  // driven entirely by an actual reachability probe: run once immediately,
  // re-run on every interface-level change (fast disconnect signal), and
  // re-run on a fixed interval so recovery is always caught even when the
  // interface itself never toggles.
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
    // dart:io sockets/DNS aren't available on the web; fall back to the
    // interface-level signal there.
    if (kIsWeb) {
      final results = await _connectivity.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    }

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(_probeTimeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on Exception {
      return false;
    }
  }
}
