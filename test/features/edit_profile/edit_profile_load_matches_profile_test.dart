import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/profile/domain/enities/profile_entity.dart';
import 'package:bingo_pay/features/profile/domain/usecase/get_profile_usecase.dart';
import 'package:bingo_pay/features/edit_profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:bingo_pay/features/edit_profile/presentation/cubit/edit_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

const _profile = ProfileEntity(
  id: 'usr_1',
  uuid: 'uuid_1',
  fullName: 'Nishant Bingo',
  email: 'nishant@bingosg.com',
  phone: '+91 9876543210',
  profileImageUrl: 'https://example.com/avatar.png',
  kycStatus: KycStatus.approved,
  emailVerified: true,
  phoneVerified: true,
);

void main() {
  late MockApiClient apiClient;
  late MockGetProfileUseCase getProfile;
  late EditProfileCubit cubit;

  setUp(() {
    apiClient = MockApiClient();
    getProfile = MockGetProfileUseCase();
    cubit = EditProfileCubit(apiClient, getProfile);
  });

  tearDown(() => cubit.close());

  test('load() shows the exact same fullName/email the Profile screen '
      '(GetProfileUseCase) returns — not a separately-fetched, '
      'possibly-out-of-sync value', () async {
    when(() => getProfile()).thenAnswer((_) async => const Right(_profile));

    await cubit.load();

    expect(cubit.state.status, EditProfileStatus.ready);
    expect(cubit.state.profile?.fullName, _profile.fullName);
    expect(cubit.state.profile?.email, _profile.email);
    expect(cubit.state.profile?.phoneNumber, _profile.phone);
    expect(cubit.state.profile?.profileImageUrl, _profile.profileImageUrl);
  });

  test(
    'load() surfaces a failure via state.status without leaving stale data',
    () async {
      when(() => getProfile()).thenAnswer(
        (_) async => const Left(
          ServerFailure(message: 'Internal server error', statusCode: 500),
        ),
      );

      await cubit.load();

      expect(cubit.state.status, EditProfileStatus.failure);
      expect(cubit.state.profile, isNull);
    },
  );
}
