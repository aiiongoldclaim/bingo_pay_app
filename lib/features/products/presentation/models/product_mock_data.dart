import 'package:flutter/foundation.dart';

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

const List<Product> _seedProducts = [
  Product(
    name: "Men's cotton t-shirt — navy",
    sku: 'TSH-1042',
    category: 'Apparel',
    price: 999,
    discountPercent: 30,
    status: ProductStatus.active,
    stock: StockInfo.inStock(),
  ),
  Product(
    name: 'Gold plated ring — size adjustable',
    sku: 'JWL-0087',
    category: 'Jewellery',
    status: ProductStatus.active,
    stock: StockInfo.lowStock(4),
  ),
  Product(
    name: 'Leather wallet — brown',
    sku: 'ACC-2210',
    category: 'Accessories',
    status: ProductStatus.draft,
    stock: StockInfo.outOfStock(),
  ),
  Product(
    name: 'Running shoes — size 9',
    sku: 'SHO-3301',
    category: 'Footwear',
    price: 2799,
    discountPercent: 21,
    status: ProductStatus.active,
    stock: StockInfo.inStock(),
  ),
  Product(
    name: 'Wireless earbuds — white',
    sku: 'ELE-5521',
    category: 'Electronics',
    price: 1499,
    status: ProductStatus.archived,
    stock: StockInfo.outOfStock(),
  ),
];

/// In-memory product list shared between the Products list screen and the
/// Add Product wizard. No backend yet — this stands in for one.
class ProductRepository extends ChangeNotifier {
  ProductRepository._() : _products = List.of(_seedProducts);

  static final ProductRepository instance = ProductRepository._();

  final List<Product> _products;

  List<Product> get products => List.unmodifiable(_products);

  List<Product> filtered(ProductFilter filter) {
    return switch (filter) {
      ProductFilter.all => products,
      ProductFilter.active => _products.where((p) => p.status == ProductStatus.active).toList(),
      ProductFilter.draft => _products.where((p) => p.status == ProductStatus.draft).toList(),
      ProductFilter.archived => _products.where((p) => p.status == ProductStatus.archived).toList(),
      ProductFilter.outOfStock =>
        _products.where((p) => p.stock.type == StockStatusType.outOfStock).toList(),
    };
  }

  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _products
      ..clear()
      ..addAll(_seedProducts);
    notifyListeners();
  }
}
