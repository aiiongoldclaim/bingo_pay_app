import 'package:bingo_pay/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  FlavorConfig(
    name: 'staging',
    color: Colors.orange,
    variables: const {
      'apiBaseUrl': 'https://stg-api.bingopay.com/v1',
      'appName': 'Bingo Pay STG',
      'enableLogging': true,
      'enableAnalytics': false,
    },
  );
  await bootstrap();
}
