import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/product_cache_service.dart';

@module
abstract class AppModule {
  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  Connectivity get connectivity => Connectivity();

  @singleton
  ProductCacheService productCacheService(SharedPreferences prefs) =>
      ProductCacheService(prefs);
}
