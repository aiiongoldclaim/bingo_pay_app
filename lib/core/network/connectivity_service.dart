import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity;

  late final Stream<bool> isConnected = _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none))
      .distinct()
      .asBroadcastStream();

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();
}
