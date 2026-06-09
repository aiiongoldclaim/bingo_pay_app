import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/flavor_config.dart';

void main() async {
  FlavorConfig.instance = const FlavorConfig(
    flavor: Flavor.dev,
    apiBaseUrl: 'https://dev-api.bingopay.com/v1',
    appName: 'Bingo Pay DEV',
    enableLogging: true,
    enableAnalytics: false,
  );
  await bootstrap();
}
