import 'package:bingo_pay/core/config/flavor_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlavorConfig', () {
    test('instance holds dev values when set to dev', () {
      FlavorConfig.instance = const FlavorConfig(
        flavor: Flavor.dev,
        apiBaseUrl: 'https://dev-api.bingopay.com/v1',
        appName: 'Bingo Pay DEV',
        enableLogging: true,
        enableAnalytics: false,
      );

      expect(FlavorConfig.instance.flavor, Flavor.dev);
      expect(FlavorConfig.instance.apiBaseUrl, 'https://dev-api.bingopay.com/v1');
      expect(FlavorConfig.instance.enableLogging, isTrue);
      expect(FlavorConfig.instance.enableAnalytics, isFalse);
    });

    test('isDev returns true only for dev flavor', () {
      FlavorConfig.instance = const FlavorConfig(
        flavor: Flavor.dev,
        apiBaseUrl: '',
        appName: '',
        enableLogging: true,
        enableAnalytics: false,
      );
      expect(FlavorConfig.instance.isDev, isTrue);
      expect(FlavorConfig.instance.isProduction, isFalse);
    });
  });
}
