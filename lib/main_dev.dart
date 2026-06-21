import 'package:bingo_pay/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  FlavorConfig(
    name: 'dev',
    color: Colors.green,
    variables: const {
      'apiBaseUrl': 'http://54.116.213.252:3001',
      'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
      'appName': 'Bingo Pay DEV',
      'enableLogging': true,
      'enableAnalytics': false,
    },
  );
  await bootstrap();
}
