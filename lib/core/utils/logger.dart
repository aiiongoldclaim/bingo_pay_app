import 'package:flutter_flavor/flutter_flavor.dart';

class AppLogger {
  static void log(String message, [Object? error, StackTrace? stackTrace]) {
    if (FlavorConfig.instance.variables['enableLogging'] as bool? ?? false) {
      if (error != null) {
        print('$message\nError: $error');
        if (stackTrace != null) {
          print(stackTrace);
        }
      } else {
        print(message);
      }
    }
  }

  static void logError(String message, Object? error, [StackTrace? stackTrace]) {
    if (FlavorConfig.instance.variables['enableLogging'] as bool? ?? false) {
      print('ERROR: $message');
      if (error != null) print('Details: $error');
      if (stackTrace != null) print(stackTrace);
    }
  }
}
