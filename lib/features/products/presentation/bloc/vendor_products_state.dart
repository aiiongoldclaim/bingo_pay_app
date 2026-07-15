import '../../data/models/vendor_product_model.dart';

abstract class VendorProductsState {}

class VendorProductsInitial extends VendorProductsState {}

class VendorProductsLoading extends VendorProductsState {}

class VendorProductsLoaded extends VendorProductsState {
  final List<VendorProductModel> all;
  final List<VendorProductModel> filtered;
  final String activeFilter;

  VendorProductsLoaded({
    required this.all,
    required this.filtered,
    required this.activeFilter,
  });
}

class VendorProductsError extends VendorProductsState {
  final String message;
  VendorProductsError(this.message);
}
