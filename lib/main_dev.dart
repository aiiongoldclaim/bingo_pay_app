import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/env_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  // Initialize environment variables
  await EnvConfig.init();

  try {
    await EnvConfig.init();
  } catch (e) {
    debugPrint('Env load failed: $e');
  }

  FlavorConfig(
    name: 'dev',
    color: Colors.green,
    variables: const {
      // 'apiBaseUrl': 'http://13.159.7.199:5001',
      'apiBaseUrl': 'https://dev.thevaults.org',
      'appName': 'Vaults DEV',
      'enableLogging': true,
      'enableAnalytics': true,
      'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
    },
  );
  await bootstrap();
}
