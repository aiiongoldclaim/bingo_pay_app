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
      stock: const StockInfo.inStock(),
      imageUrl: imageUrl,
    );
  }
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
