import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

@injectable
class AddCartItemUseCase {
  final CartRepository repository;

  const AddCartItemUseCase(this.repository);

  Future<Either<Failure, CartEntity>> call({
    required String variantUuid,
    required int quantity,
  }) {
    return repository.addItem(variantUuid: variantUuid, quantity: quantity);
  }
}
