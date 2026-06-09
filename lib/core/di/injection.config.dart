// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bingo_pay/core/api/api_client.dart' as _i541;
import 'package:bingo_pay/core/di/app_module.dart' as _i842;
import 'package:bingo_pay/core/network/connectivity_service.dart' as _i133;
import 'package:bingo_pay/core/storage/preferences_service.dart' as _i356;
import 'package:bingo_pay/core/storage/secure_storage_service.dart' as _i481;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.singleton<_i558.FlutterSecureStorage>(() => appModule.secureStorage);
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.singleton<_i895.Connectivity>(() => appModule.connectivity);
    gh.lazySingleton<_i133.ConnectivityService>(
      () => _i133.ConnectivityService(connectivity: gh<_i895.Connectivity>()),
    );
    gh.singleton<_i356.PreferencesService>(
      () => _i356.PreferencesService(gh<_i460.SharedPreferences>()),
    );
    gh.singleton<_i481.SecureStorageService>(
      () =>
          _i481.SecureStorageService(storage: gh<_i558.FlutterSecureStorage>()),
    );
    gh.singleton<_i541.ApiClient>(
      () => _i541.ApiClient(gh<_i481.SecureStorageService>()),
    );
    return this;
  }
}

class _$AppModule extends _i842.AppModule {}
