import 'package:bingo_pay/features/auth/data/models/vendor_login_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VendorLoginResultModel.fromJson', () {
    final json = {
      'vendor': {
        'uuid': 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2',
        'shopName': 'Acme Store',
        'shopSlug': 'acme-store-top',
        'status': 'PENDING',
        'verificationStatus': 'APPROVED',
        'kybStatus': 'NONE',
      },
      'user': {
        'uuid': 'f692be63-70d0-4b9f-a0d6-233444d30187',
        'fullName': 'Acme Owner',
        'email': 'owner13@acme.com',
        'phone': '9876543210',
        'roles': ['vendor'],
      },
      'session': {'id': 25, 'expiresAt': '2026-07-25T12:11:25.843Z'},
      'accessToken': 'vendor-login-jwt',
      'refreshToken': 'vendor-login-refresh-jwt',
    };

    test('extracts accessToken and refreshToken', () {
      final result = VendorLoginResultModel.fromJson(json);
      expect(result.accessToken, 'vendor-login-jwt');
      expect(result.refreshToken, 'vendor-login-refresh-jwt');
    });

    test('builds a vendor UserModel from user.uuid and vendor.verificationStatus', () {
      final result = VendorLoginResultModel.fromJson(json);
      expect(result.user.id, 'f692be63-70d0-4b9f-a0d6-233444d30187');
      expect(result.user.email, 'owner13@acme.com');
      expect(result.user.name, 'Acme Owner');
      expect(result.user.role, 'vendor');
      expect(result.user.kycStatus, 'approved');
      expect(result.user.shopName, 'Acme Store');
    });
  });
}
