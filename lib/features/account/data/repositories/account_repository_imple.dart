import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/enities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasource/account_datasource.dart';

@Injectable(as: AccountRepository)
class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource _remote;
  const AccountRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, AccountEntity>> getProfile() async {
    try {
      final response = await _remote.getProfile();
      final p = response.account;
      return Right(
        AccountEntity(
          id: p.id,
          uuid: p.uuid,
          fullName: p.fullName,
          email: p.email,
          phone: p.phone,
          profileImageUrl: p.avatar,
          kycStatus: p.kycStatus,
          emailVerified: p.emailVerified,
          phoneVerified: p.phoneVerified,
        ),
      );
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }
}
