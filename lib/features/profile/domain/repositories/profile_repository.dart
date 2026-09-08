import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../enities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
}
