import 'package:bingo_pay/features/auth/data/models/register_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterResultModel.fromBuyerJson', () {
    final json = {
      'bingold': {
        'status': 200,
        'error': false,
        'message': 'User registered successfully',
        'data': {
          'id': '9acb719a-1132-44c7-abbe-3c07291b97d7',
          'email': 'john1@example.com',
          'userRole': 'USER',
          'clientId': 'e4cd09e7-6aff-11f1-9946-0af7521c2b6b',
          'token': 'buyer-jwt',
        },
      },
      'profile': {
        'email_verified': false,
        'phone_verified': false,
        'kyc_status': 'pending',
        'id': 7,
        'uuid': '9acb719a-1132-44c7-abbe-3c07291b97d7',
        'email': 'john1@example.com',
        'phone': '9876543210',
        'first_name': 'John',
        'last_name': 'Doe',
        'bingold_user_id': null,
        'password_hash': 'should-never-be-read',
        'account_type': 'customer',
        'status': 'active',
        'updated_at': '2026-06-18T10:24:31.773Z',
        'created_at': '2026-06-18T10:24:31.773Z',
      },
      'token': 'buyer-jwt',
    };

    test('extracts accessToken from data.token', () {
      final result = RegisterResultModel.fromBuyerJson(
        json,
        firstName: 'John',
        lastName: 'Doe',
      );
      expect(result.accessToken, 'buyer-jwt');
    });

    test('builds a buyer UserModel with not_required kycStatus', () {
      final result = RegisterResultModel.fromBuyerJson(
        json,
        firstName: 'John',
        lastName: 'Doe',
      );
      expect(result.user.id, '9acb719a-1132-44c7-abbe-3c07291b97d7');
      expect(result.user.email, 'john1@example.com');
      expect(result.user.name, 'John Doe');
      expect(result.user.role, 'buyer');
      expect(result.user.kycStatus, 'not_required');
    });
  });

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
