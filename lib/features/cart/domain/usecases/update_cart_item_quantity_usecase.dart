import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

@injectable
class UpdateCartItemQuantityUseCase {
  final CartRepository repository;

  const UpdateCartItemQuantityUseCase(this.repository);

  Future<Either<Failure, CartEntity>> call({
    required int itemId,
    required int quantity,
  }) {
    return repository.updateItemQuantity(itemId: itemId, quantity: quantity);
  }
}
