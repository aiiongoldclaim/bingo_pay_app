import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/brand_entity.dart';
import '../repositories/brand_repository.dart';

@injectable
class GetBrandsUseCase {
  final BrandRepository _repository;

  GetBrandsUseCase(this._repository);

  Future<Either<Failure, List<BrandEntity>>> call() async {
    return await _repository.getBrands();
  }
}
