import 'dart:async';

import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/env_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

// Prod writes nothing to the device log: debugPrint is a no-op and every
// print() (app, packages, framework) is swallowed by this zone. The whole app
// starts inside the zone so taps, timers and futures stay in it.
void main() {
  debugPrint = (String? message, {int? wrapWidth}) {};
  runZoned(
    () async {
      // Initialize environment variables
      await EnvConfig.init();

      FlavorConfig(
        name: 'prod',
        color: Colors.transparent,
        variables: const {
          // 'apiBaseUrl': 'https://api.bingopay.com/v1',
          // 'categoriesApiBaseUrl': 'https://api.bingopay.com',
          'apiBaseUrl': 'https://dev.thevaults.to',
          'appName': 'Vaults',
          'enableLogging': false,
          'enableAnalytics': true,
          'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
        },
      );
      await bootstrap();
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {},
    ),
  );
}
