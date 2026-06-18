import 'package:bingo_pay/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('apiBaseUrl reads from FlavorConfig variables', () {
      FlavorConfig(
        name: 'dev',
        color: Colors.green,
        variables: const {
          'apiBaseUrl': 'https://dev-api.bingopay.com/v1',
        },
      );

      expect(AppConfig.apiBaseUrl, 'https://dev-api.bingopay.com/v1');
    });

    test('apiBaseUrl reflects the active flavor', () {
      FlavorConfig(
        name: 'prod',
        color: Colors.transparent,
        variables: const {
          'apiBaseUrl': 'https://api.bingopay.com/v1',
        },
      );

      expect(AppConfig.apiBaseUrl, 'https://api.bingopay.com/v1');
    });

    test('apiKey reads from FlavorConfig variables', () {
      FlavorConfig(
        name: 'dev',
        color: Colors.green,
        variables: const {
          'apiBaseUrl': 'https://admin-blog.bingold.to/api',
          'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
        },
      );

      expect(AppConfig.apiKey, 'GTP_2026_PDA_V1_API_KEY_ASDF');
    });
  });
}
