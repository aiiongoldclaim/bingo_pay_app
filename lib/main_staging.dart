import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/flavor_config.dart';
import 'package:flutter/material.dart';

void main() async {
  FlavorConfig.instance = const FlavorConfig(
    flavor: Flavor.staging,
    apiBaseUrl: 'https://stg-api.bingopay.com/v1',
    appName: 'Bingo Pay STG',
    enableLogging: true,
    enableAnalytics: false,
  );
  await bootstrap(() => const Placeholder());
}
