import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/flavor_config.dart';

void main() async {
  FlavorConfig.instance = const FlavorConfig(
    flavor: Flavor.prod,
    apiBaseUrl: 'https://api.bingopay.com/v1',
    appName: 'Bingo Pay',
    enableLogging: false,
    enableAnalytics: true,
  );
  await bootstrap();
}
