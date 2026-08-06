import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/env_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  // Initialize environment variables
  await EnvConfig.init();

  FlavorConfig(
    name: 'staging',
    color: Colors.orange,
    variables: const {
      'apiBaseUrl': 'https://stg-api.bingopay.com',
      'appName': 'Vaults STG',
      'enableLogging': true,
      'enableAnalytics': false,
      'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
    },
  );
  await bootstrap();
}
