import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../membershipNew/data/models/member_ship_model.dart';
import '../../../membershipNew/domain/repositories/membership_repository.dart';
import '../../../wishlist/data/repositories/wishlist_repository.dart';
import '../../data/models/product_details_model.dart';
import 'product_details_state.dart';


const Map<String, IconData> _pdpBenefitIcons = {
  'FREE_DELIVERY': Icons.local_shipping_outlined,
  'WARRANTY': Icons.verified_user_outlined,
  'RETURNS': Icons.autorenew_rounded,
};

@injectable
class ProductDetailCubit extends Cubit<ProductDetailState> {
  final WishlistRepository _repository;
  final MembershipRepository _membershipRepository;

  ProductDetailCubit(this._repository, this._membershipRepository)
      : super(const ProductDetailLoading());

  Future<void> loadProduct(String uuid) async {
    if (isClosed) return;
    emit(const ProductDetailLoading());
    try {
      final product = await _repository.getProductDetail(uuid);

      if (isClosed) return;

      final benefits = await _resolveBenefits();
      if (isClosed) return;

      emit(
        ProductDetailLoaded(
          product: product.copyWith(benefits: benefits),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(ProductDetailError(e.toString()));
    }
  }

  Future<List<ProductBenefit>> _resolveBenefits() async {
    final MembershipModel membership;
    try {
      membership = await _membershipRepository.getMembership();
    } catch (_) {
      return const [];
    }

    return [
      for (final entry in _pdpBenefitIcons.entries)
        if (membership.entitlements[entry.key]?.enabled ?? false)
          ProductBenefit(
            icon: entry.value,
            label: membership.entitlements[entry.key]!.name,
            subtitle: membership.entitlements[entry.key]!.valueLabel,
          ),
    ];
  }

  void selectVariant(int index) {
    final current = state;
    if (current is! ProductDetailLoaded) return;
    final updatedProduct = current.product.copyWith(selectedVariantIndex: index);
    emit(current.copyWith(
      product: updatedProduct,
      selectedVariantIndex: index,
      quantity: 1,
    ));
  }

  void selectColor(int index) {
    final current = state;
    if (current is! ProductDetailLoaded) return;
    emit(current.copyWith(selectedColorIndex: index));
  }

  void incrementQuantity() {
    final current = state;
    if (current is! ProductDetailLoaded) return;
    if (current.quantity >= current.product.availableStock) return;
    emit(current.copyWith(quantity: current.quantity + 1));
  }

  void decrementQuantity() {
    final current = state;
    if (current is! ProductDetailLoaded) return;
    if (current.quantity <= 1) return;
    emit(current.copyWith(quantity: current.quantity - 1));
  }

  void onAddToCart() {}

  void onBuyNow() {}
}
