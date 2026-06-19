import 'product_mock_data.dart';

/// Mutable holder for the non-text-field state of the Add Product wizard
/// (text fields live in TextEditingControllers on the screen, matching the
/// existing register_screen.dart pattern).
class ProductDraft {
  String? category;
  String? subCategory;
  String? gstSlab;
  bool taxInclusive = true;
  bool trackInventory = true;
  int stockQty = 0;
  bool allowBackorders = false;
  final List<String> imagePaths = [];
  ProductStatus status = ProductStatus.active;
  bool featured = false;
}
