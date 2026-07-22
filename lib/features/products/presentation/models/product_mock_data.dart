enum ProductStatus { active, draft, pending, archived }

enum StockStatusType { inStock, lowStock, outOfStock }

class StockInfo {
  final StockStatusType type;
  final int? lowStockCount;

  const StockInfo.inStock()
    : type = StockStatusType.inStock,
      lowStockCount = null;
  const StockInfo.lowStock(int count)
    : type = StockStatusType.lowStock,
      lowStockCount = count;
  const StockInfo.outOfStock()
    : type = StockStatusType.outOfStock,
      lowStockCount = null;
}

class Product {
  final String uuid;
  final String name;
  final String sku;
  final String category;
  final double? price;
  final int? discountPercent;
  final ProductStatus status;
  final StockInfo stock;
  final String? imageUrl;

  const Product({
    required this.uuid,
    required this.name,
    required this.sku,
    required this.category,
    required this.status,
    required this.stock,
    this.price,
    this.discountPercent,
    this.imageUrl,
  });

  factory Product.fromApi(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final status = switch ((json['status'] as String?)?.toUpperCase()) {
      'PUBLISHED' => ProductStatus.active,
      'DRAFT' => ProductStatus.draft,
      'ARCHIVED' => ProductStatus.archived,
      'PENDING_ADMIN_APPROVAL' => ProductStatus.pending,
      _ => json['isPublished'] == true ? ProductStatus.active : ProductStatus.draft,
    };

    final media = json['media'];
    String? imageUrl;
    if (media is List && media.isNotEmpty) {
      final primary = media.whereType<Map>().where((m) => m['isPrimary'] == true).firstOrNull;
      final fallback = media.whereType<Map>().firstOrNull;
      imageUrl = (primary ?? fallback)?['url']?.toString();
    }

    return Product(
      uuid: json['uuid']?.toString() ?? '',
      name: json['title']?.toString() ?? '',
      sku: json['slug']?.toString() ?? '',
      category: category?['name']?.toString() ?? '',
      price: null,
      discountPercent: null,
      status: status,
      stock: _stockFromVariants(json['variants']),
      imageUrl: imageUrl,
    );
  }
}

// Stock lives under each variant's inventory.availableStock (with
// lowStockThreshold for the low-stock cutoff), not a flat field on the
// product itself.
StockInfo _stockFromVariants(dynamic variantsJson) {
  if (variantsJson is! List || variantsJson.isEmpty) {
    return const StockInfo.outOfStock();
  }

  var total = 0;
  var anyLow = false;
  for (final v in variantsJson) {
    if (v is! Map) continue;
    final inventory = v['inventory'];
    final available = inventory is Map
        ? int.tryParse(inventory['availableStock']?.toString() ?? '') ?? 0
        : 0;
    final threshold = int.tryParse(v['lowStockThreshold']?.toString() ?? '') ?? 0;
    total += available;
    if (available > 0 && available <= threshold) anyLow = true;
  }

  if (total <= 0) return const StockInfo.outOfStock();
  if (anyLow) return StockInfo.lowStock(total);
  return const StockInfo.inStock();
}

enum ProductFilter { all, active, pending, draft, outOfStock, archived }

extension ProductFilterLabel on ProductFilter {
  String get label => switch (this) {
    ProductFilter.all => 'All',
    ProductFilter.active => 'Active',
    ProductFilter.pending => 'Pending',
    ProductFilter.draft => 'Draft',
    ProductFilter.outOfStock => 'Out of stock',
    ProductFilter.archived => 'Archived',
  };
}

List<Product> filterProducts(List<Product> products, ProductFilter filter) {
  return switch (filter) {
    ProductFilter.all => products,
    ProductFilter.active => products.where((p) => p.status == ProductStatus.active).toList(),
    ProductFilter.pending => products.where((p) => p.status == ProductStatus.pending).toList(),
    ProductFilter.draft => products.where((p) => p.status == ProductStatus.draft).toList(),
    ProductFilter.archived => products.where((p) => p.status == ProductStatus.archived).toList(),
    ProductFilter.outOfStock => products.where((p) => p.stock.type == StockStatusType.outOfStock).toList(),
  };
}
