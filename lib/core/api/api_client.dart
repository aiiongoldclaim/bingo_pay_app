import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

@singleton
class ApiClient {
  late final Dio dio;

  ApiClient(SecureStorageService storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout:
            const Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout:
            const Duration(seconds: AppConfig.receiveTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': AppConfig.apiKey
        },
      ),
    );

    dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(storage),
      ErrorInterceptor(),
    ]);
  }
}
