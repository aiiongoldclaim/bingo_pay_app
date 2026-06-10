import 'package:flutter_flavor/flutter_flavor.dart';

enum Flavor { dev, staging, prod }

extension AppFlavorConfig on FlavorConfig {
  Flavor get appFlavor => Flavor.values.firstWhere(
        (f) => f.name == name,
        orElse: () => throw StateError(
          'FlavorConfig.name "$name" does not match any Flavor. '
          'Call FlavorConfig(name: "dev"|"staging"|"prod", ...) before use.',
        ),
      );

  bool get isDev => name == 'dev';
  bool get isStaging => name == 'staging';
  bool get isProduction => name == 'prod';
}
