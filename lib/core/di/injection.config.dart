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
import 'package:bingo_pay/core/services/product_cache_service.dart' as _i734;
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
import 'package:bingo_pay/features/address/data/datasources/address_remote_datasources.dart'
    as _i915;
import 'package:bingo_pay/features/address/data/repositories/address_repository_impl.dart'
    as _i279;
import 'package:bingo_pay/features/address/domain/repositories/address_respository.dart'
    as _i874;
import 'package:bingo_pay/features/address/presentation/cubit/address_cubit.dart'
    as _i456;
import 'package:bingo_pay/features/auctions/data/datasources/auctions_remote_datasources.dart'
    as _i230;
import 'package:bingo_pay/features/auctions/data/repositories/auction_repository_impl.dart'
    as _i141;
import 'package:bingo_pay/features/auctions/domain/repositories/auction_repository.dart'
    as _i321;
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_cubit.dart'
    as _i1054;
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
import 'package:bingo_pay/features/auth/domain/usecases/send_otp_usecase.dart'
    as _i674;
import 'package:bingo_pay/features/auth/domain/usecases/send_sso_login_otp_usecase.dart'
    as _i137;
import 'package:bingo_pay/features/auth/domain/usecases/set_password_usecase.dart'
    as _i100;
import 'package:bingo_pay/features/auth/domain/usecases/submit_kyc_personal_details_usecase.dart'
    as _i627;
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_document_usecase.dart'
    as _i343;
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_selfie_usecase.dart'
    as _i520;
import 'package:bingo_pay/features/auth/domain/usecases/verify_otp_usecase.dart'
    as _i99;
import 'package:bingo_pay/features/auth/domain/usecases/verify_sso_login_usecase.dart'
    as _i999;
import 'package:bingo_pay/features/auth/presentation/bloc/auth_bloc.dart'
    as _i357;
import 'package:bingo_pay/features/bookings/data/datasources/booking_remote_datasources.dart'
    as _i570;
import 'package:bingo_pay/features/bookings/data/repositories/booking_repository_impl.dart'
    as _i53;
import 'package:bingo_pay/features/bookings/domain/repositories/booking_repository.dart'
    as _i623;
import 'package:bingo_pay/features/bookings/presentation/cubit/booking_cubit.dart'
    as _i1004;
import 'package:bingo_pay/features/cart/data/datasources/cart_remote_datasource.dart'
    as _i882;
import 'package:bingo_pay/features/cart/data/repositories/cart_repository_impl.dart'
    as _i263;
import 'package:bingo_pay/features/cart/domain/repositories/cart_repository.dart'
    as _i939;
import 'package:bingo_pay/features/cart/domain/usecases/add_cart_item_usecase.dart'
    as _i439;
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart'
    as _i15;
import 'package:bingo_pay/features/cart/domain/usecases/get_cart_usecase.dart'
    as _i92;
import 'package:bingo_pay/features/cart/domain/usecases/remove_cart_item_usecase.dart'
    as _i881;
import 'package:bingo_pay/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart'
    as _i876;
import 'package:bingo_pay/features/cart/presentation/cubit/cart_cubit.dart'
    as _i728;
import 'package:bingo_pay/features/categories/data/datasources/brand_remote_datasource.dart'
    as _i30;
import 'package:bingo_pay/features/categories/data/datasources/category_remote_datasource.dart'
    as _i298;
import 'package:bingo_pay/features/categories/data/repositories/brand_repository_impl.dart'
    as _i755;
import 'package:bingo_pay/features/categories/data/repositories/category_repository_impl.dart'
    as _i611;
import 'package:bingo_pay/features/categories/domain/repositories/brand_repository.dart'
    as _i105;
import 'package:bingo_pay/features/categories/domain/repositories/category_repository.dart'
    as _i298;
import 'package:bingo_pay/features/categories/domain/usecases/get_brands_usecase.dart'
    as _i152;
import 'package:bingo_pay/features/categories/domain/usecases/get_categories_usecase.dart'
    as _i507;
import 'package:bingo_pay/features/categories/presentation/cubit/categories_cubit.dart'
    as _i801;
import 'package:bingo_pay/features/customer/dashboard/presentation/cubit/buyer_dashboard_cubit.dart'
    as _i709;
import 'package:bingo_pay/features/edit_profile/presentation/cubit/edit_profile_cubit.dart'
    as _i126;
import 'package:bingo_pay/features/home/data/repositories/all_products_repo.dart'
    as _i666;
import 'package:bingo_pay/features/home/domain/repositories/product_repository_impl.dart'
    as _i297;
import 'package:bingo_pay/features/membershipNew/data/datasource/membership_remote_data_source.dart'
    as _i578;
import 'package:bingo_pay/features/membershipNew/data/repositories/membership_repository_impl.dart'
    as _i828;
import 'package:bingo_pay/features/membershipNew/domain/repositories/membership_repository.dart'
    as _i389;
import 'package:bingo_pay/features/membershipNew/presentation/cubit/membership_cubit.dart'
    as _i359;
import 'package:bingo_pay/features/on_boarding/presentation/cubit/onbording_cubit.dart'
    as _i272;
import 'package:bingo_pay/features/orders/cubit/orders_cubit.dart' as _i610;
import 'package:bingo_pay/features/orders/data/datasources/orders_remote_datasource.dart'
    as _i705;
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart'
    as _i792;
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
import 'package:bingo_pay/features/services/data/datasources/services_remote_datasource.dart'
    as _i570;
import 'package:bingo_pay/features/services/domain/usecases/get_service_detail_usecase.dart'
    as _i838;
import 'package:bingo_pay/features/services/domain/usecases/get_services_usecase.dart'
    as _i254;
import 'package:bingo_pay/features/services/presentation/cubit/services_cubit.dart'
    as _i393;
import 'package:bingo_pay/features/transactions/cubit/transactions_cubit.dart'
    as _i729;
import 'package:bingo_pay/features/transactions/data/datasources/transactions_remote_datasource.dart'
    as _i97;
import 'package:bingo_pay/features/wishlist/data/repositories/wishlist_repository.dart'
    as _i971;
import 'package:bingo_pay/features/wishlist/domain/repositories/wishlist_repository_impl.dart'
    as _i215;
import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart'
    as _i115;
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
    gh.factory<_i272.OnboardingCubit>(() => _i272.OnboardingCubit());
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
    gh.factory<_i337.PaymentRemoteDataSource>(
      () => const _i337.PaymentRemoteDataSourceImpl(),
    );
    gh.singleton<_i481.SecureStorageService>(
      () =>
          _i481.SecureStorageService(storage: gh<_i558.FlutterSecureStorage>()),
    );
    gh.singleton<_i356.PreferencesService>(
      () => _i356.PreferencesService(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i115.WishlistCubit>(
      () => _i115.WishlistCubit(gh<_i460.SharedPreferences>()),
    );
    gh.singleton<_i541.ApiClient>(
      () => _i541.ApiClient(gh<_i481.SecureStorageService>()),
    );
    gh.singleton<_i734.ProductCacheService>(
      () => appModule.productCacheService(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i30.BrandRemoteDataSource>(
      () => _i30.BrandRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.factory<_i763.AuthLocalDataSource>(
      () => _i763.AuthLocalDataSourceImpl(
        gh<_i481.SecureStorageService>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.factory<_i758.PaymentRepository>(
      () => _i461.PaymentRepositoryImpl(gh<_i337.PaymentRemoteDataSource>()),
    );
    gh.lazySingleton<_i666.ProductRepository>(
      () => _i297.ProductRepositoryImpl(
        apiClient: gh<_i541.ApiClient>(),
        cacheService: gh<_i734.ProductCacheService>(),
      ),
    );
    gh.factory<_i882.CartRemoteDataSource>(
      () => _i882.CartRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.factory<_i105.BrandRepository>(
      () => _i755.BrandRepositoryImpl(gh<_i30.BrandRemoteDataSource>()),
    );
    gh.factory<_i705.OrdersRemoteDataSource>(
      () => _i705.OrdersRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.factory<_i570.ServiceRemoteDataSource>(
      () => _i570.ServiceRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.lazySingleton<_i578.MembershipRemoteDataSource>(
      () => _i578.MembershipRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.factory<_i152.GetBrandsUseCase>(
      () => _i152.GetBrandsUseCase(gh<_i105.BrandRepository>()),
    );
    gh.factory<_i298.CategoryRemoteDataSource>(
      () => _i298.CategoryRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.lazySingleton<_i389.MembershipRepository>(
      () => _i828.MembershipRepositoryImpl(
        gh<_i578.MembershipRemoteDataSource>(),
      ),
    );
    gh.factory<_i570.BookingRemoteDatasources>(
      () => _i570.BookingRemoteDatasources(gh<_i541.ApiClient>()),
    );
    gh.singleton<_i792.BigodPaymentDataSource>(
      () => _i792.BigodPaymentDataSource(gh<_i541.ApiClient>()),
    );
    gh.factory<_i915.AddressRemoteDataSource>(
      () => _i915.AddressRemoteDataSource(gh<_i541.ApiClient>()),
    );
    gh.factory<_i230.AuctionsRemoteDatasources>(
      () => _i230.AuctionsRemoteDatasources(gh<_i541.ApiClient>()),
    );
    gh.factory<_i126.EditProfileCubit>(
      () => _i126.EditProfileCubit(gh<_i541.ApiClient>()),
    );
    gh.factory<_i495.AuthRemoteDataSource>(
      () => _i495.AuthRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.factory<_i633.AccountRemoteDataSource>(
      () => _i633.AccountRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.lazySingleton<_i971.WishlistRepository>(
      () => _i215.ProductDetailRepositoryImpl(apiClient: gh<_i541.ApiClient>()),
    );
    gh.factory<_i97.TransactionsRemoteDataSource>(
      () => _i97.TransactionsRemoteDataSourceImpl(gh<_i541.ApiClient>()),
    );
    gh.factory<_i805.ProcessPaymentUseCase>(
      () => _i805.ProcessPaymentUseCase(gh<_i758.PaymentRepository>()),
    );
    gh.factory<_i298.CategoryRepository>(
      () => _i611.CategoryRepositoryImpl(gh<_i298.CategoryRemoteDataSource>()),
    );
    gh.factory<_i359.MembershipCubit>(
      () => _i359.MembershipCubit(gh<_i389.MembershipRepository>()),
    );
    gh.factory<_i939.CartRepository>(
      () => _i263.CartRepositoryImpl(gh<_i882.CartRemoteDataSource>()),
    );
    gh.factory<_i439.AddCartItemUseCase>(
      () => _i439.AddCartItemUseCase(gh<_i939.CartRepository>()),
    );
    gh.factory<_i15.ClearCartUseCase>(
      () => _i15.ClearCartUseCase(gh<_i939.CartRepository>()),
    );
    gh.factory<_i92.GetCartUseCase>(
      () => _i92.GetCartUseCase(gh<_i939.CartRepository>()),
    );
    gh.factory<_i881.RemoveCartItemUseCase>(
      () => _i881.RemoveCartItemUseCase(gh<_i939.CartRepository>()),
    );
    gh.factory<_i876.UpdateCartItemQuantityUseCase>(
      () => _i876.UpdateCartItemQuantityUseCase(gh<_i939.CartRepository>()),
    );
    gh.factory<_i728.CartCubit>(
      () => _i728.CartCubit(
        gh<_i92.GetCartUseCase>(),
        gh<_i439.AddCartItemUseCase>(),
        gh<_i876.UpdateCartItemQuantityUseCase>(),
        gh<_i881.RemoveCartItemUseCase>(),
        gh<_i15.ClearCartUseCase>(),
      ),
    );
    gh.factory<_i623.BookingRepository>(
      () => _i53.BookingRepositoryImpl(gh<_i570.BookingRemoteDatasources>()),
    );
    gh.factory<_i610.OrdersCubit>(
      () => _i610.OrdersCubit(gh<_i705.OrdersRemoteDataSource>()),
    );
    gh.factory<_i507.GetCategoriesUseCase>(
      () => _i507.GetCategoriesUseCase(gh<_i298.CategoryRepository>()),
    );
    gh.factory<_i610.OrderDetailCubit>(
      () => _i610.OrderDetailCubit(
        gh<_i705.OrdersRemoteDataSource>(),
        gh<_i915.AddressRemoteDataSource>(),
      ),
    );
    gh.factory<_i874.AddressRepository>(
      () => _i279.AddressRepositoryImpl(gh<_i915.AddressRemoteDataSource>()),
    );
    gh.factory<_i321.AuctionRepository>(
      () => _i141.AuctionRepositoryImpl(gh<_i230.AuctionsRemoteDatasources>()),
    );
    gh.factory<_i631.PaymentCubit>(
      () => _i631.PaymentCubit(gh<_i805.ProcessPaymentUseCase>()),
    );
    gh.factory<_i917.AuthRepository>(
      () => _i1061.AuthRepositoryImpl(
        gh<_i495.AuthRemoteDataSource>(),
        gh<_i763.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i838.GetServiceDetailUseCase>(
      () => _i838.GetServiceDetailUseCase(gh<_i570.ServiceRemoteDataSource>()),
    );
    gh.factory<_i838.GetServiceAvailabilityUseCase>(
      () => _i838.GetServiceAvailabilityUseCase(
        gh<_i570.ServiceRemoteDataSource>(),
      ),
    );
    gh.factory<_i254.GetServicesUseCase>(
      () => _i254.GetServicesUseCase(gh<_i570.ServiceRemoteDataSource>()),
    );
    gh.factory<_i372.AccountRepository>(
      () => _i85.AccountRepositoryImpl(gh<_i633.AccountRemoteDataSource>()),
    );
    gh.factory<_i729.TransactionsCubit>(
      () => _i729.TransactionsCubit(gh<_i97.TransactionsRemoteDataSource>()),
    );
    gh.factory<_i393.AvailabilityCubit>(
      () => _i393.AvailabilityCubit(gh<_i838.GetServiceAvailabilityUseCase>()),
    );
    gh.factory<_i801.CategoriesCubit>(
      () => _i801.CategoriesCubit(
        gh<_i507.GetCategoriesUseCase>(),
        gh<_i152.GetBrandsUseCase>(),
      ),
    );
    gh.factory<_i456.AddressCubit>(
      () => _i456.AddressCubit(gh<_i874.AddressRepository>()),
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
    gh.factory<_i674.SendOtpUseCase>(
      () => _i674.SendOtpUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i137.SendSsoLoginOtpUseCase>(
      () => _i137.SendSsoLoginOtpUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i100.SetPasswordUseCase>(
      () => _i100.SetPasswordUseCase(gh<_i917.AuthRepository>()),
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
    gh.factory<_i999.VerifySsoLoginUseCase>(
      () => _i999.VerifySsoLoginUseCase(gh<_i917.AuthRepository>()),
    );
    gh.factory<_i1054.AuctionCubit>(
      () => _i1054.AuctionCubit(gh<_i321.AuctionRepository>()),
    );
    gh.factory<_i1004.BookingCubit>(
      () => _i1004.BookingCubit(gh<_i623.BookingRepository>()),
    );
    gh.factory<_i393.ServicesCubit>(
      () => _i393.ServicesCubit(gh<_i254.GetServicesUseCase>()),
    );
    gh.factory<_i393.ServiceDetailCubit>(
      () => _i393.ServiceDetailCubit(gh<_i838.GetServiceDetailUseCase>()),
    );
    gh.factory<_i741.AccountCubit>(
      () => _i741.AccountCubit(gh<_i810.GetProfileUseCase>()),
    );
    gh.singleton<_i357.AuthBloc>(
      () => _i357.AuthBloc(
        checkAuthStatus: gh<_i308.CheckAuthStatusUseCase>(),
        login: gh<_i368.LoginUseCase>(),
        register: gh<_i721.RegisterUseCase>(),
        verifyOtp: gh<_i99.VerifyOtpUseCase>(),
        sendOtp: gh<_i674.SendOtpUseCase>(),
        resendOtp: gh<_i869.ResendOtpUseCase>(),
        forgotPassword: gh<_i878.ForgotPasswordUseCase>(),
        logout: gh<_i189.LogoutUseCase>(),
        checkEmailExists: gh<_i80.CheckEmailExistsUseCase>(),
        sendSsoLoginOtp: gh<_i137.SendSsoLoginOtpUseCase>(),
        verifySsoLogin: gh<_i999.VerifySsoLoginUseCase>(),
        setPassword: gh<_i100.SetPasswordUseCase>(),
        kycPersonalDetails: gh<_i627.SubmitKycPersonalDetailsUseCase>(),
        kycDocument: gh<_i343.UploadKycDocumentUseCase>(),
        kycSelfie: gh<_i520.UploadKycSelfieUseCase>(),
        getKycStatus: gh<_i894.GetKycStatusUseCase>(),
        storage: gh<_i481.SecureStorageService>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i842.AppModule {}
