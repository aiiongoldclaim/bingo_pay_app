import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/repositories/brand_repository.dart';
import '../datasources/brand_remote_datasource.dart';

@Injectable(as: BrandRepository)
class BrandRepositoryImpl implements BrandRepository {
  final BrandRemoteDataSource _remoteDatasource;

  BrandRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, List<BrandEntity>>> getBrands() async {
    try {
      final brands = await _remoteDatasource.getBrands();
      return Right(
        brands
            .map((b) => BrandEntity(
                  id: b.id,
                  uuid: b.uuid,
                  name: b.name,
                  logo: b.logo,
                  description: b.description,
                  isActive: b.isActive,
                ))
            .toList(),
      );
    } catch (e) {
      return Left(
        e is Exception
            ? ErrorHandler.mapExceptionToFailure(e)
            : ErrorHandler.mapExceptionToFailure(Exception(e.toString())),
      );
    }
  }
}
