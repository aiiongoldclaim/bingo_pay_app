import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/enities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_datasource.dart';

@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  const ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final response = await _remote.getProfile();
      final p = response.profile;
      return Right(
        ProfileEntity(
          id: p.id,
          uuid: p.uuid,
          fullName: p.fullName,
          email: p.email,
          phone: p.phone,
          profileImageUrl: p.avatar,
          kycStatus: p.kycStatus,
          emailVerified: p.emailVerified,
          phoneVerified: p.phoneVerified,
          bigoldBalance: p.bigoldBalance,
          usdtBalance: p.usdtBalance,
          balances: p.balances,
          walletAddresses: p.walletAddresses,
        ),
      );
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }
}
