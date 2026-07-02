import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

@injectable
class GetCartUseCase {
  final CartRepository repository;

  const GetCartUseCase(this.repository);

  Future<Either<Failure, CartEntity>> call() => repository.getCart();
}
