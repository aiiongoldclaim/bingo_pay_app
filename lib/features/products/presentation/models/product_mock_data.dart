enum ProductStatus { active, draft, archived }

enum StockStatusType { inStock, lowStock, outOfStock }

class StockInfo {
  final StockStatusType type;
  final int? lowStockCount;

  const StockInfo.inStock() : type = StockStatusType.inStock, lowStockCount = null;
  const StockInfo.lowStock(int count) : type = StockStatusType.lowStock, lowStockCount = count;
  const StockInfo.outOfStock() : type = StockStatusType.outOfStock, lowStockCount = null;
}

class Product {
  final String name;
  final String sku;
  final String category;
  final double? price;
  final int? discountPercent;
  final ProductStatus status;
  final StockInfo stock;

  const Product({
    required this.name,
    required this.sku,
    required this.category,
    required this.status,
    required this.stock,
    this.price,
    this.discountPercent,
  });

  /// Maps a raw row from the Apps Script `getProducts` response. The sheet
  /// has no status column, so every product from the API is treated as active.
  factory Product.fromApi(Map<String, dynamic> json) {
    final mrp = _toDouble(json['mrp']);
    final sellingPrice = _toDouble(json['selling_price']);
    final discountPercent = (mrp != null && sellingPrice != null && sellingPrice < mrp && mrp > 0)
        ? (((mrp - sellingPrice) / mrp) * 100).round()
        : null;

    final stockQty = _toInt(json['stock_quantity']) ?? 0;
    final lowStockThreshold = _toInt(json['low_stock_threshold']) ?? 10;
    final stock = stockQty <= 0
        ? const StockInfo.outOfStock()
        : stockQty <= lowStockThreshold
        ? StockInfo.lowStock(stockQty)
        : const StockInfo.inStock();

    return Product(
      name: json['product_name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      category: json['sub_category']?.toString() ?? '',
      price: sellingPrice,
      discountPercent: discountPercent,
      status: ProductStatus.active,
      stock: stock,
    );
  }
}

double? _toDouble(dynamic value) {
  if (value == null || value == '') return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _toInt(dynamic value) {
  if (value == null || value == '') return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

enum ProductFilter { all, active, draft, outOfStock, archived }

extension ProductFilterLabel on ProductFilter {
  String get label => switch (this) {
    ProductFilter.all => 'All',
    ProductFilter.active => 'Active',
    ProductFilter.draft => 'Draft',
    ProductFilter.outOfStock => 'Out of stock',
    ProductFilter.archived => 'Archived',
  };
}

List<Product> filterProducts(List<Product> products, ProductFilter filter) {
  return switch (filter) {
    ProductFilter.all => products,
    ProductFilter.active => products.where((p) => p.status == ProductStatus.active).toList(),
    ProductFilter.draft => products.where((p) => p.status == ProductStatus.draft).toList(),
    ProductFilter.archived => products.where((p) => p.status == ProductStatus.archived).toList(),
    ProductFilter.outOfStock =>
      products.where((p) => p.stock.type == StockStatusType.outOfStock).toList(),
  };
}
