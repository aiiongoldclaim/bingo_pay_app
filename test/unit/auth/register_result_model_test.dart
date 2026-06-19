import 'package:bingo_pay/features/auth/data/models/register_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterResultModel.fromVendorJson', () {
    final json = {
      'vendor': {
        'uuid': 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2',
        'shopName': 'Acme Store',
        'shopSlug': 'acme-store-top',
        'businessName': 'Acme Pvt Ltd',
        'merchantCode': 'MER0861525',
        'status': 'pending',
        'kycStatus': 'pending',
      },
      'accessToken': 'vendor-jwt',
      'tokenType': 'Bearer',
      'bingoldToken': 'bingold-jwt',
      'bingold': {
        'status': 200,
        'error': false,
        'message': 'User registered successfully',
        'data': {
          'id': 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2',
          'email': 'owner13@acme.com',
          'userRole': 'VENDOR',
          'clientId': '92c05ab6-6af7-11f1-9946-0af7521c2b6b',
          'token': 'bingold-jwt',
        },
      },
    };

    test('extracts accessToken from data.accessToken (not bingoldToken)', () {
      final result = RegisterResultModel.fromVendorJson(
        json,
        firstName: 'Acme',
        lastName: 'Owner',
      );
      expect(result.accessToken, 'vendor-jwt');
    });

    test('builds a vendor UserModel with kycStatus from vendor.kycStatus', () {
      final result = RegisterResultModel.fromVendorJson(
        json,
        firstName: 'Acme',
        lastName: 'Owner',
      );
      expect(result.user.id, 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2');
      expect(result.user.email, 'owner13@acme.com');
      expect(result.user.name, 'Acme Owner');
      expect(result.user.role, 'vendor');
      expect(result.user.kycStatus, 'pending');
    });
  });
}
