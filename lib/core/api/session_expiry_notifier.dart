import 'dart:async';
import 'package:injectable/injectable.dart';

/// Broadcasts a single event whenever any API call comes back 401, so
/// [AuthBloc] can react by logging the user out regardless of which
/// screen/bloc happened to make the failing request.
@singleton
class SessionExpiryNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _controller.stream;

  void notify() => _controller.add(null);

  void dispose() => _controller.close();
}
