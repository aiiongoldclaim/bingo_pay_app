import 'flavor_config.dart';

class AppConfig {
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int pageSize = 20;
  static const int kycPollingIntervalSeconds = 10;

  static String get apiBaseUrl => FlavorConfig.instance.apiBaseUrl;
}
