// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bingo_pay/core/api/api_client.dart' as _i541;
import 'package:bingo_pay/core/di/app_module.dart' as _i842;
import 'package:bingo_pay/core/network/connectivity_service.dart' as _i133;
import 'package:bingo_pay/core/router/app_router.dart' as _i14;
import 'package:bingo_pay/core/storage/preferences_service.dart' as _i356;
import 'package:bingo_pay/core/storage/secure_storage_service.dart' as _i481;
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart'
    as _i763;
import 'package:bingo_pay/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i495;
import 'package:bingo_pay/features/auth/data/repositories/auth_repository_impl.dart'
    as _i1061;
import 'package:bingo_pay/features/auth/domain/repositories/auth_repository.dart'
    as _i917;
import 'package:bingo_pay/features/auth/domain/usecases/check_auth_status_usecase.dart'
    as _i308;
import 'package:bingo_pay/features/auth/domain/usecases/forgot_password_usecase.dart'
    as _i878;
import 'package:bingo_pay/features/auth/domain/usecases/get_kyc_status_usecase.dart'
    as _i894;
import 'package:bingo_pay/features/auth/domain/usecases/logout_usecase.dart'
    as _i189;
import 'package:bingo_pay/features/auth/domain/usecases/register_vendor_usecase.dart'
    as _i1029;
import 'package:bingo_pay/features/auth/domain/usecases/submit_kyc_personal_details_usecase.dart'
    as _i627;
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_document_usecase.dart'
    as _i343;
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_selfie_usecase.dart'
    as _i520;
import 'package:bingo_pay/features/auth/domain/usecases/vendor_login_usecase.dart'
    as _i984;
import 'package:bingo_pay/features/auth/presentation/bloc/auth_bloc.dart'
    as _i357;
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
    gh.lazySingleton<_i14.AppRouter>(() => _i14.AppRouter());
    gh.lazySingleton<_i133.ConnectivityService>(
      () => _i133.ConnectivityService(connectivity: gh<_i895.Connectivity>()),
    );
    gh.singleton<_i481.SecureStorageService>(
      () =>
          _i481.SecureStorageService(storage: gh<_i558.FlutterSecureStorage>()),
    );
    gh.singleton<_i356.PreferencesService>(
      () => _i356.PreferencesService(gh<_i460.SharedPreferences>()),
    );
    gh.singleton<_i541.ApiClient>(
      () => _i541.ApiClient(gh<_i481.SecureStorageService>()),
    );
    gh.factory<_i763.AuthLocalDataSource>(
      () => _i763.AuthLocalDataSourceImpl(
        gh<_i481.SecureStorageService>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.factory<_i495.AuthRemoteDataSource>(
      () => _i495.AuthRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.factory<_i917.AuthRepository>(
      () => _i1061.AuthRepositoryImpl(
        gh<_i495.AuthRemoteDataSource>(),
        gh<_i763.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i308.CheckAuthStatusUseCase>(
      () => _i308.CheckAuthStatusUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i878.ForgotPasswordUseCase>(
      () => _i878.ForgotPasswordUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i894.GetKycStatusUseCase>(
      () => _i894.GetKycStatusUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i189.LogoutUseCase>(
      () => _i189.LogoutUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i1029.RegisterVendorUseCase>(
      () => _i1029.RegisterVendorUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i627.SubmitKycPersonalDetailsUseCase>(
      () => _i627.SubmitKycPersonalDetailsUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i343.UploadKycDocumentUseCase>(
      () => _i343.UploadKycDocumentUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i520.UploadKycSelfieUseCase>(
      () => _i520.UploadKycSelfieUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i984.VendorLoginUseCase>(
      () => _i984.VendorLoginUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i357.AuthBloc>(
      () => _i357.AuthBloc(
        checkAuthStatus: gh<_i308.CheckAuthStatusUseCase>(),
        registerVendor: gh<_i1029.RegisterVendorUseCase>(),
        vendorLogin: gh<_i984.VendorLoginUseCase>(),
        forgotPassword: gh<_i878.ForgotPasswordUseCase>(),
        logout: gh<_i189.LogoutUseCase>(),
        kycPersonalDetails: gh<_i627.SubmitKycPersonalDetailsUseCase>(),
        kycDocument: gh<_i343.UploadKycDocumentUseCase>(),
        kycSelfie: gh<_i520.UploadKycSelfieUseCase>(),
        getKycStatus: gh<_i894.GetKycStatusUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i842.AppModule {}
