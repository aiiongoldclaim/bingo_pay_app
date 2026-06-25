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
import 'package:bingo_pay/features/account/data/datasource/account_datasource.dart'
    as _i633;
import 'package:bingo_pay/features/account/data/repositories/account_repository_imple.dart'
    as _i85;
import 'package:bingo_pay/features/account/domain/repositories/account_repository.dart'
    as _i372;
import 'package:bingo_pay/features/account/domain/usecase/get_account_usecase.dart'
    as _i810;
import 'package:bingo_pay/features/account/presentation/cubit/account_cubit.dart'
    as _i741;
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
import 'package:bingo_pay/features/auth/domain/usecases/check_email_exists_usecase.dart'
    as _i80;
import 'package:bingo_pay/features/auth/domain/usecases/forgot_password_usecase.dart'
    as _i878;
import 'package:bingo_pay/features/auth/domain/usecases/get_kyc_status_usecase.dart'
    as _i894;
import 'package:bingo_pay/features/auth/domain/usecases/login_usecase.dart'
    as _i368;
import 'package:bingo_pay/features/auth/domain/usecases/logout_usecase.dart'
    as _i189;
import 'package:bingo_pay/features/auth/domain/usecases/register_usecase.dart'
    as _i721;
import 'package:bingo_pay/features/auth/domain/usecases/resend_otp_usecase.dart'
    as _i869;
import 'package:bingo_pay/features/auth/domain/usecases/submit_kyc_personal_details_usecase.dart'
    as _i627;
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_document_usecase.dart'
    as _i343;
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_selfie_usecase.dart'
    as _i520;
import 'package:bingo_pay/features/auth/domain/usecases/verify_otp_usecase.dart'
    as _i99;
import 'package:bingo_pay/features/auth/presentation/bloc/auth_bloc.dart'
    as _i357;
import 'package:bingo_pay/features/categories/domain/repositories/category_repository.dart'
    as _i298;
import 'package:bingo_pay/features/categories/domain/usecases/get_categories_usecase.dart'
    as _i507;
import 'package:bingo_pay/features/customer/dashboard/presentation/cubit/buyer_dashboard_cubit.dart'
    as _i709;
import 'package:bingo_pay/features/scanner/data/datasource/payment_remote_datasource.dart'
    as _i337;
import 'package:bingo_pay/features/scanner/data/repositories/payment_repository_impl.dart'
    as _i461;
import 'package:bingo_pay/features/scanner/domain/repositories/payment_repository.dart'
    as _i758;
import 'package:bingo_pay/features/scanner/domain/usecases/process_payment_usecase.dart'
    as _i805;
import 'package:bingo_pay/features/scanner/presentation/cubit/payment_cubit.dart'
    as _i631;
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
    gh.factory<_i709.BuyerDashboardCubit>(() => _i709.BuyerDashboardCubit());
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
    gh.factory<_i507.GetCategoriesUseCase>(
      () => _i507.GetCategoriesUseCase(gh<_i298.CategoryRepository>()),
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
    gh.factory<_i337.PaymentRemoteDataSource>(
      () => _i337.PaymentRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.factory<_i495.AuthRemoteDataSource>(
      () => _i495.AuthRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.factory<_i633.AccountRemoteDataSource>(
      () => _i633.AccountRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.factory<_i758.PaymentRepository>(
      () => _i461.PaymentRepositoryImpl(gh<_i337.PaymentRemoteDataSource>()),
    );
    gh.factory<_i917.AuthRepository>(
      () => _i1061.AuthRepositoryImpl(
        gh<_i495.AuthRemoteDataSource>(),
        gh<_i763.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i372.AccountRepository>(
      () => _i85.AccountRepositoryImpl(gh<_i633.AccountRemoteDataSource>()),
    );
    gh.factory<_i805.ProcessPaymentUseCase>(
      () => _i805.ProcessPaymentUseCase(gh<_i758.PaymentRepository>()),
    );
    gh.factory<_i810.GetProfileUseCase>(
      () => _i810.GetProfileUseCase(gh<_i372.AccountRepository>()),
    );
    gh.factory<_i308.CheckAuthStatusUseCase>(
      () => _i308.CheckAuthStatusUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i80.CheckEmailExistsUseCase>(
      () => _i80.CheckEmailExistsUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i878.ForgotPasswordUseCase>(
      () => _i878.ForgotPasswordUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i894.GetKycStatusUseCase>(
      () => _i894.GetKycStatusUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i368.LoginUseCase>(
      () => _i368.LoginUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i189.LogoutUseCase>(
      () => _i189.LogoutUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i721.RegisterUseCase>(
      () => _i721.RegisterUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i869.ResendOtpUseCase>(
      () => _i869.ResendOtpUseCase(gh<_i917.AuthRepository>()),
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
    gh.factory<_i99.VerifyOtpUseCase>(
      () => _i99.VerifyOtpUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i741.AccountCubit>(
      () => _i741.AccountCubit(
        gh<_i810.GetProfileUseCase>(),
        gh<_i481.SecureStorageService>(),
      ),
    );
    gh.factory<_i357.AuthBloc>(
      () => _i357.AuthBloc(
        checkAuthStatus: gh<_i308.CheckAuthStatusUseCase>(),
        login: gh<_i368.LoginUseCase>(),
        register: gh<_i721.RegisterUseCase>(),
        verifyOtp: gh<_i99.VerifyOtpUseCase>(),
        resendOtp: gh<_i869.ResendOtpUseCase>(),
        forgotPassword: gh<_i878.ForgotPasswordUseCase>(),
        logout: gh<_i189.LogoutUseCase>(),
        checkEmailExists: gh<_i80.CheckEmailExistsUseCase>(),
        kycPersonalDetails: gh<_i627.SubmitKycPersonalDetailsUseCase>(),
        kycDocument: gh<_i343.UploadKycDocumentUseCase>(),
        kycSelfie: gh<_i520.UploadKycSelfieUseCase>(),
        getKycStatus: gh<_i894.GetKycStatusUseCase>(),
        storage: gh<_i481.SecureStorageService>(),
      ),
    );
    gh.factory<_i631.PaymentCubit>(
      () => _i631.PaymentCubit(gh<_i805.ProcessPaymentUseCase>()),
    );
    return this;
  }
}

class _$AppModule extends _i842.AppModule {}
