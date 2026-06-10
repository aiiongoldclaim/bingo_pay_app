import 'package:flutter_flavor/flutter_flavor.dart';

enum Flavor { dev, staging, prod }

extension AppFlavorConfig on FlavorConfig {
  Flavor get appFlavor => Flavor.values.firstWhere(
        (f) => f.name == FlavorConfig.instance.name,
      );

  bool get isDev => FlavorConfig.instance.name == 'dev';
  bool get isStaging => FlavorConfig.instance.name == 'staging';
  bool get isProduction => FlavorConfig.instance.name == 'prod';
}
