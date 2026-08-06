import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/env_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  // Initialize environment variables
  await EnvConfig.init();

  FlavorConfig(
    name: 'prod',
    color: Colors.transparent,
    variables: const {
      // 'apiBaseUrl': 'https://api.bingopay.com/v1',
      // 'categoriesApiBaseUrl': 'https://api.bingopay.com',
      'apiBaseUrl': 'http://13.159.7.199:5001',
      'appName': 'Vaults',
      'enableLogging': true,
      'enableAnalytics': true,
      'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
    },
  );
  await bootstrap();
}
