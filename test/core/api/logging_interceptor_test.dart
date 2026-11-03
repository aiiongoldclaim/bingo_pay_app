import 'package:bingo_pay/core/api/interceptors/logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('request log hides the wallet PIN, OTP and passwords', () {
    FlavorConfig(variables: {'enableLogging': true});
    final lines = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) => lines.add(message ?? '');
    addTearDown(() => debugPrint = original);

    LoggingInterceptor().onRequest(
      RequestOptions(
        path: '/api/v1/tvs-wallet/pin',
        data: {
          'pin': '4826',
          'currentPin': '1357',
          'otp': '621081',
          'newPassword': 'S3cret!',
          'amount': '50',
        },
      ),
      RequestInterceptorHandler(),
    );

    final log = lines.join('\n');
    for (final secret in ['4826', '1357', '621081', 'S3cret!']) {
      expect(log, isNot(contains(secret)));
    }
    expect(log, contains('amount: 50'));
  });
}
