import 'package:bingo_pay/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  FlavorConfig(
    name: 'dev',
    color: Colors.green,
    variables: const {
      // 'apiBaseUrl': 'http://54.116.213.252:3001',
      'apiBaseUrl': 'http://13.159.7.199:5001',
      'categoriesApiBaseUrl': 'http://13.159.7.199:5001',
      'appName': 'Bingo Pay DEV',
      'enableLogging': true,
      'enableAnalytics': false,
      'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
    },
  );
  await bootstrap();
}
