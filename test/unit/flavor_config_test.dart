import 'package:bingo_pay/core/config/flavor_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFlavorConfig extension', () {
    test('isDev returns true for dev flavor', () {
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

      expect(FlavorConfig.instance.isDev, isTrue);
      expect(FlavorConfig.instance.isStaging, isFalse);
      expect(FlavorConfig.instance.isProduction, isFalse);
    });

    test('isStaging returns true for staging flavor', () {
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

      expect(FlavorConfig.instance.isStaging, isTrue);
      expect(FlavorConfig.instance.isDev, isFalse);
      expect(FlavorConfig.instance.isProduction, isFalse);
    });

    test('isProduction returns true for prod flavor', () {
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

      expect(FlavorConfig.instance.isProduction, isTrue);
      expect(FlavorConfig.instance.isDev, isFalse);
      expect(FlavorConfig.instance.isStaging, isFalse);
    });

    test('appFlavor maps flavor string to Flavor enum', () {
      FlavorConfig(
        name: 'staging',
        color: Colors.orange,
        variables: const {},
      );

      expect(FlavorConfig.instance.appFlavor, Flavor.staging);
    });
  });
}
