import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/brand_entity.dart';

abstract interface class BrandRepository {
  Future<Either<Failure, List<BrandEntity>>> getBrands();
}
