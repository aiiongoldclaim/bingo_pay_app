import 'package:bingo_pay/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  FlavorConfig(
    name: 'dev',
    color: Colors.green,
    variables: const {
      'apiBaseUrl': 'https://dev-api.bingopay.com/v1',
      'appName': 'Bingo Pay DEV',
      'enableLogging': true,
      'enableAnalytics': false,
    },
  );
  await bootstrap();
}
