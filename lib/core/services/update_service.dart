import 'dart:async';
import 'package:in_app_update/in_app_update.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@singleton
class UpdateService {
  late StreamController<UpdateAvailable?> _updateController;
  final _logger = Logger();

  Stream<UpdateAvailable?> get updateStream => _updateController.stream;

  UpdateService() {
    _updateController = StreamController<UpdateAvailable?>.broadcast();
  }

  Future<void> checkForUpdates({bool forceShowUpdate = false}) async {
    try {
      // For testing: force show update without Play Store check
      if (forceShowUpdate) {
        _logger.w('🧪 TEST MODE: Forcing update display');
        await Future.delayed(Duration(milliseconds: 500));
        _updateController.add(UpdateAvailable(
          packageName: 'com.bingo.pay',
          updatePriority: 5,
        ));
        return;
      }

      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _updateController.add(UpdateAvailable(
          packageName: info.packageName,
          updatePriority: info.updatePriority,
        ));
      }
    } catch (e) {
      _logger.e('Error checking for updates: $e');
    }
  }

  Future<void> startFlexibleUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();
    } catch (e) {
      _logger.e('Error starting flexible update: $e');
    }
  }

  Future<void> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      _logger.e('Error completing flexible update: $e');
    }
  }

  void dismissUpdate() {
    _updateController.add(null);
  }

  void dispose() {
    _updateController.close();
  }
}

class UpdateAvailable {
  final String packageName;
  final int updatePriority;

  UpdateAvailable({
    required this.packageName,
    required this.updatePriority,
  });
}
