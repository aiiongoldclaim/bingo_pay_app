import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/enities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../account_model/account_data_model.dart';
import '../account_model/account_profile_response.dart';
import '../datasource/account_datasource.dart';

@Injectable(as: AccountRepository)
class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource _remote;
  const AccountRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, AccountEntity>> getProfile({
    required String email,
  }) async {
    try {
      final response = await _remote.getProfile(email: email);
      return Right(_toEntity(response));
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  // ── Mapper: data model → domain entity ────────────────────────────────────

  static AccountEntity _toEntity(AccountResponseModel response) {
    final p = response.account;

    return AccountEntity(
      id: p.id,
      uuid: p.uuid,
      firstName: p.firstName,
      lastName: p.lastName,
      email: p.email,
      phone: p.phone,
      profileImageUrl: p.bingoldProfile.profileImage,
      kycStatus: KycStatus.fromString(p.kycStatus),
      emailVerified: p.emailVerified,
      phoneVerified: p.phoneVerified,
      referralCode: p.bingoldProfile.referralCode,
      bigoldBalance: p.bigoldBalance,
      usdtBalance: p.usdtBalance,
      walletAddresses: WalletAddresses(
        eth: p.walletAddresses.eth,
        usdt: p.walletAddresses.usdt,
        busd: p.walletAddresses.busd,
        bnb: p.walletAddresses.bnb,
      ),
      balances: p.balances
          .map(
            (e) => CryptoBalance(
              coin: e.coin,
              fullName: e.fullName,
              address: e.address,
              balance: e.balance,
              totalBalance: e.totalBalance,
              iconUrl: e.iconUrl,
              isWithdrawDisabled: e.isWithdrawDisabled,
            ),
          )
          .toList(),
    );
  }

  static CryptoBalance _toBalanceEntity(CryptoBalanceModel m) {
    return CryptoBalance(
      coin: m.coin,
      fullName: m.fullName,
      address: m.address,
      balance: m.balance,
      totalBalance: m.totalBalance,
      iconUrl: m.iconUrl,
      isWithdrawDisabled: m.isWithdrawDisabled,
    );
  }
}
