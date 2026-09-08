import 'dart:async';

import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/profile/domain/enities/profile_entity.dart';
import 'package:bingo_pay/features/profile/domain/usecase/get_profile_usecase.dart';
import 'package:bingo_pay/features/edit_profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:bingo_pay/features/edit_profile/presentation/screens/edit_profile_screen.dart';
import 'package:bingo_pay/features/edit_profile/presentation/widgets/edit_profile_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

const _profile = ProfileEntity(
  id: 'usr_1',
  uuid: 'uuid_1',
  fullName: 'Nishant Bingo',
  email: 'nishant@bingosg.com',
  phone: '+91 9876543210',
  kycStatus: KycStatus.approved,
  emailVerified: true,
  phoneVerified: true,
);

Widget _wrap(EditProfileCubit cubit) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    home: BlocProvider<EditProfileCubit>.value(
      value: cubit,
      child: const EditProfileScreen(),
    ),
  ),
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

  testWidgets(
    'the edit-profile shimmer renders (not a bare spinner) while load() is '
    'in flight, then the loaded email/name match GetProfileUseCase (same '
    'source as the Profile screen)',
    (tester) async {
      final gate = Completer<Either<Failure, ProfileEntity>>();
      when(() => getProfile()).thenAnswer((_) => gate.future);

      await tester.pumpWidget(_wrap(cubit));
      // Don't settle — load() is still in flight.
      await tester.pump();

      expect(find.byType(EditProfileShimmer), findsOneWidget);
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
        reason: 'the shimmer replaces the old bare spinner',
      );

      gate.complete(Right(_profile));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileShimmer), findsNothing);
      expect(
        find.text(_profile.email),
        findsOneWidget,
        reason: 'the email shown must be the Profile screen\'s email',
      );
      expect(
        find.text(_profile.fullName),
        findsOneWidget,
        reason: 'the name shown must be the Profile screen\'s name',
      );
    },
  );
}
