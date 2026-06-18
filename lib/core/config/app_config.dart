import 'package:flutter_flavor/flutter_flavor.dart';

class AppConfig {
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int pageSize = 20;
  static const int kycPollingIntervalSeconds = 10;

  static String get apiBaseUrl =>
      FlavorConfig.instance.variables['apiBaseUrl'] as String;

  static String get apiKey =>
      FlavorConfig.instance.variables['apiKey'] as String;
}
