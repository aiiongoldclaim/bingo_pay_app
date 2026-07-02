import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';

import '../datasources/cart_remote_datasource.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';

@Injectable(as: CartRepository)
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remote;

  const CartRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final cart = await _remote.getCart();
      return Right(_toEntity(cart));
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addItem({
    required String variantUuid,
    required int quantity,
  }) async {
    try {
      final cart = await _remote.addItem(
        variantUuid: variantUuid,
        quantity: quantity,
      );
      return Right(_toEntity(cart));
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateItemQuantity({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final cart = await _remote.updateItemQuantity(
        itemId: itemId,
        quantity: quantity,
      );
      return Right(_toEntity(cart));
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> removeItem({required int itemId}) async {
    try {
      final message = await _remote.removeItem(itemId: itemId);
      return Right(message);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> clearCart() async {
    try {
      final message = await _remote.clearCart();
      return Right(message);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  CartEntity _toEntity(CartModel model) => CartEntity(
    cartId: model.cartId,
    cartUuid: model.cartUuid,
    totalItems: model.totalItems,
    totalAmount: model.totalAmount,
    items: model.items.map(_itemToEntity).toList(),
  );

  CartItemEntity _itemToEntity(CartItemModel item) => CartItemEntity(
    id: item.id,
    quantity: item.quantity,
    unitPrice: item.unitPrice,
    totalPrice: item.totalPrice,
    product: CartProductEntity(
      uuid: item.product.uuid,
      title: item.product.title,
      slug: item.product.slug,
      thumbnail: item.product.thumbnail,
    ),
    variant: CartVariantEntity(
      uuid: item.variant.uuid,
      sku: item.variant.sku,
      stock: item.variant.stock,
      attributes: item.variant.attributes
          .map(
            (a) => CartVariantAttributeEntity(
              attribute: a.attribute,
              value: a.value,
            ),
          )
          .toList(),
    ),
    vendor: CartVendorEntity(
      uuid: item.vendor.uuid,
      shopName: item.vendor.shopName,
    ),
  );
}
