import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';

abstract interface class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();

  Future<Either<Failure, CartEntity>> addItem({
    required String variantUuid,
    required int quantity,
  });

  Future<Either<Failure, CartEntity>> updateItemQuantity({
    required int itemId,
    required int quantity,
  });

  Future<Either<Failure, String>> removeItem({required int itemId});

  Future<Either<Failure, String>> clearCart();
}
