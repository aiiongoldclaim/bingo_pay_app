import 'product_mock_data.dart';

class VariantDraft {
  String? uuid;
  String title;
  double? basePrice;
  double? salePrice;
  double? costPrice;
  String sku;
  String barcode;
  int stock;
  bool isDefault;
  final Map<String, String> attributeValues; // attributeUuid → value

  VariantDraft({
    this.uuid,
    this.title = '',
    this.basePrice,
    this.salePrice,
    this.costPrice,
    this.sku = '',
    this.barcode = '',
    this.stock = 0,
    this.isDefault = false,
    Map<String, String>? attributeValues,
  }) : attributeValues = attributeValues ?? {};

  Map<String, dynamic> toPayload() => {
    if (title.trim().isNotEmpty) 'title': title.trim(),
    if (basePrice != null) 'basePrice': basePrice,
    if (salePrice != null) 'salePrice': salePrice,
    if (costPrice != null) 'costPrice': costPrice,
    if (sku.trim().isNotEmpty) 'sku': sku.trim(),
    if (barcode.trim().isNotEmpty) 'barcode': barcode.trim(),
    'stock': stock,
    'isDefault': isDefault,
    if (attributeValues.isNotEmpty)
      'attributes': attributeValues.entries
          .map((e) => {'attributeUuid': e.key, 'optionId': int.tryParse(e.value) ?? e.value})
          .toList(),
  };
}

class ProductDraft {
  String? category;
  String? categoryUuid;
  String? subCategory;
  String? subCategoryUuid;
  String? brand;
  String? brandUuid;
  String? gstSlab;
  bool taxInclusive = true;
  bool trackInventory = true;
  int stockQty = 0;
  bool allowBackorders = false;
  final List<String> imagePaths = [];
  // Maps uploaded URL → server media ID for deletion
  final Map<String, String> imageMediaIds = {};
  ProductStatus status = ProductStatus.active;
  bool featured = false;
  final Map<String, String> specifications = {};
  final List<VariantDraft> variants = [];
}
