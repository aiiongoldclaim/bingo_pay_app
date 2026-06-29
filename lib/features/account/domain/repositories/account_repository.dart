import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../enities/account_entity.dart';

abstract class AccountRepository {
  Future<Either<Failure, AccountEntity>> getProfile();
}
