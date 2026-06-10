import 'package:bingo_pay/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  FlavorConfig(
    name: 'prod',
    color: Colors.transparent,
    variables: const {
      'apiBaseUrl': 'https://api.bingopay.com/v1',
      'appName': 'Bingo Pay',
      'enableLogging': false,
      'enableAnalytics': true,
    },
  );
  await bootstrap();
}
