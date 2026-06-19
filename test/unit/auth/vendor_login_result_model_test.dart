import 'package:bingo_pay/features/auth/data/models/vendor_login_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VendorLoginResultModel.fromJson', () {
    final json = {
      'vendor': {
        'uuid': 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2',
        'shopName': 'Acme Store',
        'shopSlug': 'acme-store-top',
        'businessName': 'Acme Pvt Ltd',
        'merchantCode': 'MER0861525',
        'status': 'active',
        'kycStatus': 'approved',
        'kycMode': null,
      },
      'accessToken': 'vendor-login-jwt',
      'tokenType': 'Bearer',
      'bingoldProfile': {
        'status': 200,
        'error': false,
        'message': 'User profile fetched successfully',
        'data': {
          'id': 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2',
          'email': 'owner13@acme.com',
          'status': 'ACTIVE',
          'phoneNumber': '9876543210',
          'userDetail': {
            'firstName': 'Acme',
            'lastName': 'Owner',
            'countryId': '91',
          },
        },
      },
    };

    test('extracts accessToken from the top-level accessToken field', () {
      final result = VendorLoginResultModel.fromJson(json);
      expect(result.accessToken, 'vendor-login-jwt');
    });

    test('builds a vendor UserModel from vendor + bingoldProfile.data', () {
      final result = VendorLoginResultModel.fromJson(json);
      expect(result.user.id, 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2');
      expect(result.user.email, 'owner13@acme.com');
      expect(result.user.name, 'Acme Owner');
      expect(result.user.role, 'vendor');
      expect(result.user.kycStatus, 'approved');
      expect(result.user.shopName, 'Acme Store');
      expect(result.user.merchantCode, 'MER0861525');
      expect(result.user.businessName, 'Acme Pvt Ltd');
    });
  });
}
